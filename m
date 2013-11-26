From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: Re: [PATCH 06/17] net: cisco-enic calls skb_get_rxhash
Date: Tue, 26 Nov 2013 17:26:05 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1311261713030.3174@gmail.com>
References: <alpine.DEB.2.02.1311252150050.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Christian Benvenuti (benve)" <benve@cisco.com>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	Tom Herbert <therbert@google.com>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:50534 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830Ab3KZL4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 06:56:23 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so7870262pbb.37
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 03:56:23 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311252150050.22983@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 25 Nov 2013, Tom Herbert wrote:

> Drivers should call skb_get_rxhash to set the rxhash and its type in an skbuff.
                           ^^^
It should be skb_set_rxhash right? I would like to have 'git log' show
correct information.

Otherwise this patch looks fine for me.

Acked-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>

>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> drivers/net/ethernet/cisco/enic/enic_main.c | 11 ++++++-----
> 1 file changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index ff78dfa..ea30551 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -1036,11 +1036,12 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
> 		skb->protocol = eth_type_trans(skb, netdev);
> 		skb_record_rx_queue(skb, q_number);
> 		if (netdev->features & NETIF_F_RXHASH) {
> -			skb->rxhash = rss_hash;
> -			if (rss_type & (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
> -					NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
> -					NIC_CFG_RSS_HASH_TYPE_TCP_IPV4))
> -				skb->l4_rxhash = true;
> +			skb_set_rxhash(skb, rss_hash,
> +			    (rss_type & (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
> +					 NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
> +					 NIC_CFG_RSS_HASH_TYPE_TCP_IPV4)) ?
> +			     RXHASH_TYPE_L4 : RXHASH_TYPE_L3);
> +
> 		}
>
> 		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
> -- 
> 1.8.4.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
