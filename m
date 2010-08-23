From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 802.1q: make vlan_hwaccel_do_receive() return void
Date: Sun, 22 Aug 2010 21:03:04 -0700 (PDT)
Message-ID: <20100822.210304.200379828.davem@davemloft.net>
References: <1282519918-10874-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750717Ab0HWECr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:02:47 -0400
In-Reply-To: <1282519918-10874-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 23 Aug 2010 07:31:58 +0800

> @@ -2841,8 +2841,8 @@ static int __netif_receive_skb(struct sk_buff *skb)
>  	if (!netdev_tstamp_prequeue)
>  		net_timestamp_check(skb);
>  
> -	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
> -		return NET_RX_SUCCESS;
> +	if (vlan_tx_tag_present(skb))
> +		vlan_hwaccel_do_receive(skb);
>  

Ok, I see how this happened.  The code here first came from
Patrick:

commit 9b22ea560957de1484e6b3e8538f7eef202e3596
 ...
    net: fix packet socket delivery in rx irq handler

And back then vlan_hwaccel_do_receive() returned "-1" and freed the
packet if cb->dev was NULL.

Herbert then added the GRO containers in:

commit e1c096e251e52773afeffbbcb74d0a072be47ea3
 ...
    vlan: Add GRO interfaces

where skb->dev now stores what cb->dev used to, and the "-1"
return and cb->dev check were thus removed.

Anyways, with how things stand now this patch looks fine and
I'll apply it to net-next-2.6, thanks!
