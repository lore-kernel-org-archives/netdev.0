From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [GIT PATCH] IPv6 Routing / Ndisc Fixes
Date: Wed, 23 Aug 2006 17:40:18 -0700 (PDT)
Message-ID: <20060823.174018.59657195.davem@davemloft.net>
References: <44D9D431.10101@tcs.hut.fi>
	<44DA558A.1080706@tcs.hut.fi>
	<20060810.174635.42119608.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19607
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965257AbWHXAkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:40:16 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060810.174635.42119608.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 10 Aug 2006 17:46:35 +0900 (JST)

> Hello.
> 
> In article <44DA558A.1080706@tcs.hut.fi> (at Thu, 10 Aug 2006 00:37:14 +0300), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> 
> > >> commit e0ad64d5b44179ea1296d737dec23279c72c9636
> > >> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > >> Date:   Wed Aug 9 17:08:33 2006 +0900
> > >>
> > >>     [IPV6] NDISC: Allow redirects from other interfaces if it is not strict.
> > >>     
> > >>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > >>
> > >> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > >> index 4650787..1698fec 100644
> > >> --- a/net/ipv6/route.c
> > >> +++ b/net/ipv6/route.c
> > >> @@ -1322,7 +1322,7 @@ restart:
> > >>  			continue;
> > >>  		if (!(rt->rt6i_flags & RTF_GATEWAY))
> > >>  			continue;
> > >> -		if (fl->oif != rt->rt6i_dev->ifindex)
> > >> +		if ((flags & RT6_F_STRICT) && fl->oif != rt->rt6i_dev->ifindex)
> > >>  			continue;
> > >>  		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
> > >>  			continue;
> > >>
> > > 
> > > Is this absolutely safe? Doesn't this enable a malicious node on another
> > > link to make a bogus redirect if it uses same link-local source address
> > > as the real router on the other link. Keep in mind that the RT6_F_STRICT
> > > flag is set based on the destination of the original redirected packet
> > > and doesn't in any way depend on the router or source address.
> :
> 
> Ah, you're right.  I'll drop this.

Ok, I integrated all of these changes, dropping this RT6_F_STRICT
changeset, and integrating all of Ville's sign offs and ACKs.

It is all in the net-2.6.19 tree, thanks a lot.

I will start to review the MIPV6 patches next.

