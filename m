From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Fri, 7 Dec 2007 13:23:36 +0900
Message-ID: <20071207132336.a503ec4e.mitch@linux.vnet.ibm.com>
References: <20071206171421.1495c019.mitch@linux.vnet.ibm.com>
	<20071206084733.GB2164@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Rami Rosen <roszenrami@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53628 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbXLGEYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 23:24:13 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB74OC7T023305
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 23:24:12 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB74O7DG071526
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 21:24:12 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB74O6L5025885
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 21:24:07 -0700
In-Reply-To: <20071206084733.GB2164@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Dec 2007 09:47:33 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On 06-12-2007 09:14, Mitsuru Chinen wrote:
> > On Thu, 6 Dec 2007 08:49:47 +0100
> > Jarek Poplawski <jarkao2@o2.pl> wrote:
> > 
> >> On 06-12-2007 07:31, Mitsuru Chinen wrote:
> >>> IPv4 stack doesn't reply any ICMP destination unreachable message
> >>> with net unreachable code when IP detagrams are being discarded
> >>> because of no route could be found in the forwarding path.
> >>> Incidentally, IPv6 stack replies such ICMPv6 message in the similar
> >>> situation.
> ...
> >> This patch seems to be wrong. It overrides err codes from
> >> fib_lookup, where such decisions should be made.
> > 
> > fib_lookup() replies -ESRCH in this situation.
> > It is necessary to override the variable by the suitable error
> > number like the code under e_hostunreach label.
> 
> Probably I miss something, but I can't see how can you be sure it's
> only -ESRCH possible here? Isn't opt->action() in fib_rules_lookup()
> supposed to return this -ENETUNREACH when needed?

Oh, excuse me. I did mistake.
fib_rules_lookup() replies -ESRCH when no route is found. The case
it replies -ENETUNREACH is that user adds unreachable route.
However, if the err value is override with no check, a blackhole
or prohibit route is treated as a unreachable route.

As the patch is already applied, I will send another patch to add
a check for it.
Thank you very much for pointing out the issue!

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>
