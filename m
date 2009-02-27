From: David Miller <davem@davemloft.net>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 00:03:50 -0800 (PST)
Message-ID: <20090227.000350.107894710.davem@davemloft.net>
References: <20090226.041037.134928084.davem@davemloft.net>
	<20090226130631.GA14125@gondor.apana.org.au>
	<20090227041136.GA21468@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754247AbZB0IEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 03:04:07 -0500
In-Reply-To: <20090227041136.GA21468@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 27 Feb 2009 12:11:36 +0800

>  /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
>  int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  		      u16 vlan_tci, int polling)
>  {
> +	if (netpoll_receive_skb(skb))
> +		return NET_RX_DROP;
> +
>  	if (skb_bond_should_drop(skb))
>  		goto drop;
>  

This case should use netpoll_rx().

netif_rx_skb() --> netpoll_rx()
netif_receive_skb() --> netpoll_receive_skb()
