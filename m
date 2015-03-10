From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH net-next v2 1/1] net: fec: fix receive VLAN CTAG HW
 acceleration issue
Date: Tue, 10 Mar 2015 12:41:02 +0100
Message-ID: <20150310114102.GB22614@pengutronix.de>
References: <1425985781-25736-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel@pengutronix.de
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38192 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbCJLlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 07:41:06 -0400
Content-Disposition: inline
In-Reply-To: <1425985781-25736-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 07:09:41PM +0800, Fugang Duan wrote:
> The current driver support receive VLAN CTAG HW acceleration feature
> (NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls the
> api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but there
> have overlap between the two memory data point range. The patch just fix
> the issue.
> 
> V2:
> Michael Grzeschik suggest to use memmove() instead of skb_copy_to_linear_data_offset().

This probably is not welcome in the patch description.

How about?

Cc: <stable@vger.kernel.org> # back to commit 1b7bde6d6

Michael

> Reported-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 9bb6220..92b7e9a 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1479,8 +1479,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
>  
>  			vlan_packet_rcvd = true;
>  
> -			skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
> -						       data, (2 * ETH_ALEN));
> +			memmove(skb->data + VLAN_HLEN, data, ETH_ALEN * 2);
>  			skb_pull(skb, VLAN_HLEN);
>  		}
>  
> -- 
> 1.7.8




-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
