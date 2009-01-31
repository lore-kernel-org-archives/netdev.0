From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 11:37:24 +0300
Message-ID: <20090131083724.GB26897@ioremap.net>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:54844 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbZAaIhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 03:37:25 -0500
Content-Disposition: inline
In-Reply-To: <20090130185224.214b3a59@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 06:52:24PM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
> My working hypothesis is:
>   1. Something about Evgeniy's patch makes IPV6 (actually IPV4 in IPV6) be
>      preferred over plain IPV4.
>   2. Vino server (VNC) doesn't think ::ffff::127.0.0.1 is really the localhost
>   3. protocol gets screwed up after that.
> 
> It is probably reproducible with other services that support IPV6.

getaddrinfo() returns list of addresses and IPv6 was the first one iirc.
Previously it bailed out, but with my change it will try again without
reason for doing this. With the patch I sent based on Eric's observation
things should be fine.

-- 
	Evgeniy Polyakov
