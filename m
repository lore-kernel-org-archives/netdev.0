From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Fri, 11 Jul 2014 13:00:35 +0200
Message-ID: <20140711110035.GB6633@secunet.com>
References: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Karl Heiss <kheiss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35667 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195AbaGKLAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 07:00:47 -0400
Content-Disposition: inline
In-Reply-To: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 10:57:21AM -0400, Karl Heiss wrote:
> I believe I have found an issue whereby IPv4 fragments arriving
> out-of-order will cause an IPSEC tunnel to stop passing any traffic
> which arrived fragmented, citing 'SA-icv-failure'.  

Why do you think the arriving order causes our problems? SA-icv-failure
means that the integrity check failed and this is independent of the
packet order, unless you use 64 bit extended sequence numbers (ESN).
I would guess you don't use ESN because you noticed these problems
already with v2.6.32 and this had no ESN support.

If this happens just with fragmented packets, I'd guess there is a
problem when packets get fragmented after IPsec and reassembled
before IPsec processing.

> Packets which were
> not fragmented will validate and pass successfully, even once the
> condition has been triggered.  I have decrypted the traffic and have
> verified that the traffic is arriving correctly.  It appears as if the
> condition persists until all connections are closed.
> 
> The issue was originally discovered in RHEL 6.5 (2.6.32-431.11.2.el6)
> kernel and verified with Fedora 20 running 3.15.0-rc8-nn on x86_64.
> 
> The easiest way I have found to reproduce the issue is to use a kernel
> without commit c08751c851b78514f6ec5 (Fix data chunk fragmentation for
> MTU values which are not multiple of 4) to generate fragmented SCTP
> traffic using multiple single-homed connections.  

Do you have some odd MTU/PMTU value on this route? If so, you might
get post IPsec fragmented packets without that commit.

I have a lot of testcases where I test PMTU discovery and fragmentation
with IPsec. I've never seen such problems, but I don't use sctp. Is there
any chance to reproduce this with another protocol?
