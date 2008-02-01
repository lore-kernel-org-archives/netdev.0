From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: update MSS even if MTU is unchanged
Date: Thu, 31 Jan 2008 16:37:36 -0800 (PST)
Message-ID: <20080131.163736.46142971.davem@davemloft.net>
References: <20080121105227.GA8306@jim.sh>
	<20080121220248.GA25284@jim.sh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jim@jtan.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753706AbYBAAhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:37:15 -0500
In-Reply-To: <20080121220248.GA25284@jim.sh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Paris <jim@jtan.com>
Date: Mon, 21 Jan 2008 17:02:48 -0500

> This is needed because in ndisc.c, we have:
> 
>   static void ndisc_router_discovery(struct sk_buff *skb)
>   {
>   // ...
>   	if (ndopts.nd_opts_mtu) {
>   // ...
>   			if (rt)
>   				rt->u.dst.metrics[RTAX_MTU-1] = mtu;
> 
>   			rt6_mtu_change(skb->dev, mtu);
>   // ...
>   }
> 
> Since the mtu is set directly here, rt6_mtu_change_route thinks that
> it is unchanged, and so it fails to update the MSS accordingly.  This
> patch lets rt6_mtu_change_route still update MSS if old_mtu == new_mtu.
> 
> Signed-off-by: Jim Paris <jim@jtan.com>

This seems ok, patch applied, thanks.
