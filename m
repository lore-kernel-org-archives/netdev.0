From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] [GIT PATCH] IPv6 Routing / Ndisc Fixes
Date: Thu, 10 Aug 2006 17:46:35 +0900 (JST)
Message-ID: <20060810.174635.42119608.yoshfuji@linux-ipv6.org>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>
	<44D9D431.10101@tcs.hut.fi>
	<44DA558A.1080706@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53519 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1161154AbWHJIo7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 04:44:59 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <44DA558A.1080706@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <44DA558A.1080706@tcs.hut.fi> (at Thu, 10 Aug 2006 00:37:14 +0300), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> >> commit e0ad64d5b44179ea1296d737dec23279c72c9636
> >> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> >> Date:   Wed Aug 9 17:08:33 2006 +0900
> >>
> >>     [IPV6] NDISC: Allow redirects from other interfaces if it is not strict.
> >>     
> >>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> >>
> >> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> >> index 4650787..1698fec 100644
> >> --- a/net/ipv6/route.c
> >> +++ b/net/ipv6/route.c
> >> @@ -1322,7 +1322,7 @@ restart:
> >>  			continue;
> >>  		if (!(rt->rt6i_flags & RTF_GATEWAY))
> >>  			continue;
> >> -		if (fl->oif != rt->rt6i_dev->ifindex)
> >> +		if ((flags & RT6_F_STRICT) && fl->oif != rt->rt6i_dev->ifindex)
> >>  			continue;
> >>  		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
> >>  			continue;
> >>
> > 
> > Is this absolutely safe? Doesn't this enable a malicious node on another
> > link to make a bogus redirect if it uses same link-local source address
> > as the real router on the other link. Keep in mind that the RT6_F_STRICT
> > flag is set based on the destination of the original redirected packet
> > and doesn't in any way depend on the router or source address.
:

Ah, you're right.  I'll drop this.

As a result of original lookup (with possible ambiguous outout interface),
one interface for original output is selected.
Which means, we have a route for the (original) destination through that
interface.

Redirects shall come from that interface.
So, it is enough to lookup routes on that interface.

Thanks.

--yoshfuji
