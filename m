From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
	dropped after ~40 seconds
Date: Fri, 18 Dec 2009 11:41:23 +0000
Message-ID: <20091218114123.GA8310@ff.dom.local>
References: <bug-14794-10286@http.bugzilla.kernel.org/> <20091216154713.f082e7cf.akpm@linux-foundation.org> <4B2A9A40.90203@freemail.hu> <20091217132451.b168a796.akpm@linux-foundation.org> <4B2AA64C.50709@gmail.com> <4B2B35B7.6060703@freemail.hu> <adaskb83df6.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:45970 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbZLRLle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 06:41:34 -0500
Received: by fxm21 with SMTP id 21so2711286fxm.21
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 03:41:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <adaskb83df6.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2009 at 12:16:13AM -0800, Roland Dreier wrote:
> 
>  > Unfortunately reverting the commit 61cbe54d9479ad98283b2dda686deae4c34b2d59 on
>  > top of 2.6.32 does not solve the problem.
> 
> Is there any possibility that one of the steps of the bisection was
> wrong?  Could you possibly have accidentally marked a "bad" kernel as
> "good"?
> 
> Addresses like 169.254.123.251 are RFC 3297 zeroconf link-local
> addresses.  I think network manager will assign one of those if it
> thinks the DHCP negotiation failed.
> 
> It might be informative to compare the network manager and dhclient log
> output (maybe in /var/log/daemon.log?) in the good and bad cases.

Btw, I'm not sure if it matters, but your dmesg doesn't mirror what
you described. You mentioned one unplug only, while there are a few
link down / link up events visible. So I wonder if bad contact didn't
happen here. Then dhcp client might hit some limit of tries. On the
other hand, such an effect could be amplified by changes in 2.6.32
too (e.g. with different timing). Could you attach 2.6.31 dmesg after
this test?

Jarek P.
