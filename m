From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 02/10] vxlan: handle skb_clone failure
Date: Wed, 5 Jun 2013 08:50:29 -0400
Message-ID: <OF46C80482.502E42A2-ON85257B81.00466F0E-85257B81.004689F6@us.ibm.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org> <1370406254-6341-2-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:36635 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab3FEMuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 08:50:35 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 5 Jun 2013 06:50:35 -0600
In-Reply-To: <1370406254-6341-2-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: David L Stevens <dlstevens@us.ibm.com>

> From: Stephen Hemminger <stephen@networkplumber.org>
 
> skb_clone can fail if out of memory. Just skip the fanout.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
> Does not impact stable, this was introduced by the multiple
> destination code.
> ---
>  drivers/net/vxlan.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 536082a..9085c81 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1197,9 +1197,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff 
> *skb, struct net_device *dev)
>        struct sk_buff *skb1;
> 
>        skb1 = skb_clone(skb, GFP_ATOMIC);
> -      rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> -      if (rc == NETDEV_TX_OK)
> -         rc = rc1;
> +      if (skb1) {
> +         rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> +         if (rc == NETDEV_TX_OK)
> +            rc = rc1;
> +      }
>     }
> 
>     rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
