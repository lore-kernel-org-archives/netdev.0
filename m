From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/13] bridge: Allow tail-call on br_pass_frame_up
Date: Sat, 27 Feb 2010 03:14:51 -0800 (PST)
Message-ID: <20100227.031451.21192400.davem@davemloft.net>
References: <20100226153410.GA26419@gondor.apana.org.au>
	<E1Nl2Db-0006v3-21@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965569Ab0B0LOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 06:14:33 -0500
In-Reply-To: <E1Nl2Db-0006v3-21@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 26 Feb 2010 23:35:07 +0800

> @@ -20,9 +20,9 @@
>  /* Bridge group multicast address 802.1d (pg 51). */
>  const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
>  
> -static void br_pass_frame_up(struct net_bridge *br, struct sk_buff *skb)
> +static int br_pass_frame_up(struct sk_buff *skb)
>  {
> -	struct net_device *indev, *brdev = br->dev;
> +	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
>  

You use this new BR_INPUT_SKB_CB() here in patch #2, but you only
start setting ->brdev it in patch #4.

This breaks things and makes your patch series non-bisectable.

Please fix, thanks.
