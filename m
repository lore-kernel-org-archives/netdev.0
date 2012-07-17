From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: timer expiry check at icmp.c in ipv6
Date: Tue, 17 Jul 2012 07:39:23 +0200
Message-ID: <1342503563.2626.38.camel@edumazet-glaptop>
References: <4A71D24947E78D43BC584A7CD4391A41017DBBAF@SIXPRD0410MB359.apcprd04.prod.outlook.com>
	 ,<1342449217.2830.3.camel@edumazet-glaptop>
	 <4A71D24947E78D43BC584A7CD4391A41017DBDB4@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33862 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab2GQFja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:39:30 -0400
Received: by eaak11 with SMTP id k11so6769eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 22:39:27 -0700 (PDT)
In-Reply-To: <4A71D24947E78D43BC584A7CD4391A41017DBDB4@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 05:11 +0000, BALAKUMARAN KANNAN wrote:
> Dear Eric,
>     Can you please explain it into bit further. Actually what I want
> to know is how the preferred lifetime value of a router advertisement
> is processed?, Where it is stored? and while sending the ICMP_REPLY
> how that preferred lifetime value considered before actually sending
> the packet? I cannot able to find the relation between
> icmpv6_echo_reply and fib6_run_gc(). I am very new to kernel source.
> Kindly help me.

# find net/ipv6|xargs grep -n RTF_EXPIRES
net/ipv6/ip6_fib.c:675:				if (!(iter->rt6i_flags & RTF_EXPIRES))
net/ipv6/ip6_fib.c:677:				if (!(rt->rt6i_flags & RTF_EXPIRES))
net/ipv6/ip6_fib.c:740:	    (rt->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
net/ipv6/ip6_fib.c:1545:	if (rt->rt6i_flags & RTF_EXPIRES && rt->dst.expires) {
net/ipv6/route.c:307:	if (!(rt->rt6i_flags & RTF_EXPIRES) && dst->from)
net/ipv6/route.c:370:	if (rt->rt6i_flags & RTF_EXPIRES) {
net/ipv6/route.c:375:		return (ort->rt6i_flags & RTF_EXPIRES) &&
net/ipv6/route.c:1397:	if (cfg->fc_flags & RTF_EXPIRES)
net/ipv6/route.c:1908:				  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
net/ipv6/route.c:2476:	if (!(rt->rt6i_flags & RTF_EXPIRES))
net/ipv6/addrconf.c:805:			} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
net/ipv6/addrconf.c:1902:				flags |= RTF_EXPIRES;
net/ipv6/addrconf.c:2212:		flags = RTF_EXPIRES;
net/ipv6/addrconf.c:3420:		flags = RTF_EXPIRES;
net/ipv6/ip6_fib.c.orig:675:				if (!(iter->rt6i_flags & RTF_EXPIRES))
net/ipv6/ip6_fib.c.orig:677:				if (!(rt->rt6i_flags & RTF_EXPIRES))
net/ipv6/ip6_fib.c.orig:740:	    (rt->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
net/ipv6/ip6_fib.c.orig:1545:	if (rt->rt6i_flags & RTF_EXPIRES && rt->dst.expires) {



What are the expected preferred lifetimes of a router ?

If granularity is one second, the garbage collection done every 30
seconds is not good.

But if its one hour, or one day, having a 30 seconds delay at the end of
the period isnt critical.
