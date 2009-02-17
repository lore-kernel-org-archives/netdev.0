From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: [PATCH v2] Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 12:05:24 +0100
Message-ID: <499A99F4.60405@hiramoto.org>
References: <20090216232016.GA4803@ami.dom.local> <499A7D7D.1090607@trash.net> <20090217093908.GB5341@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-green-bigip-177.dreamhost.com ([208.97.132.177]:48677 "EHLO
	spunkymail-a5.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751047AbZBQLFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 06:05:31 -0500
In-Reply-To: <20090217093908.GB5341@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jarek Poplawski wrote:
> Sorry:
> -----------------> take 2: changelog fix only
>
> vlan: Update skb->mac_header in __vlan_put_tag().
>
> After moving mac addresses in __vlan_put_tag() skb->mac_header needs
> to be updated.
>   
This works on IPoE.  I notice no change with or w/o this patch on IPoE
only routing.    However has no effect on the original problem i
reported with  IPoA --> NAT --> VLAN

Tested-by: Karl Hiramoto <karl@hiramoto.org>

> Reported-by: Karl Hiramoto <karl@hiramoto.org>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>
>  include/linux/if_vlan.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index f8ff918..e1ff5b1 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -210,6 +210,7 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
>  
>  	/* Move the mac addresses to the beginning of the new header. */
>  	memmove(skb->data, skb->data + VLAN_HLEN, 2 * VLAN_ETH_ALEN);
> +	skb->mac_header -= VLAN_HLEN;
>  
>  	/* first, the ethernet type */
>  	veth->h_vlan_proto = htons(ETH_P_8021Q);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   

