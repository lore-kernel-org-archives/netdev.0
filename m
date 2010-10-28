From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] via-velocity: Codestyle fixes
Date: Wed, 27 Oct 2010 21:15:18 -0700
Message-ID: <1288239318.1836.7.camel@Joe-Laptop>
References: <1288237684-30783-1-git-send-email-alex@wigen.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alex@wigen.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3639 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab0J1EPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 00:15:19 -0400
In-Reply-To: <1288237684-30783-1-git-send-email-alex@wigen.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-28 at 13:48 +1000, alex@wigen.net wrote:
> From: Alexander Wigen <alex@wigen.net>
> @@ -1542,7 +1542,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
>  	 *	Fill in the descriptor to match
>  	 */
>  
> -	*((u32 *) & (rd->rdesc0)) = 0;
> +	*((u32 *) &(rd->rdesc0)) = 0;

I think this style change isn't really that good.
rdesc0 is:

struct rdesc0 {
	__le16 RSR;		/* Receive status */
	__le16 len;		/* bits 0--13; bit 15 - owner */
};

I think it more sensible to either set the fields
in the struct to 0 or to memset the struct to 0.

> @@ -1681,7 +1681,7 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
>  static void velocity_free_dma_rings(struct velocity_info *vptr)
>  {
>  	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
> -		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
> +		vptr->options.numtx * sizeof(struct tx_desc) *vptr->tx.numq;

If checkpatch warns about this, it's wrong.

> @@ -2477,24 +2477,24 @@ static struct net_device_stats *velocity_get_stats(struct net_device *dev)
>  	dev->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
>  	dev->stats.rx_length_errors = vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
>  
> -//  unsigned long   rx_dropped;     /* no space in linux buffers    */
> +/*  unsigned long   rx_dropped;     /* no space in linux buffers    */

why not just remove all these commented-out lines?

> @@ -2957,7 +2957,7 @@ static int velocity_set_wol(struct velocity_info *vptr)
>  		memcpy(arp->ar_tip, vptr->ip_addr, 4);
>  
>  		crc = wol_calc_crc((sizeof(struct arp_packet) + 7) / 8, buf,
> -				(u8 *) & mask_pattern[0][0]);
> +				(u8 *) &mask_pattern[0][0]);

perhaps just (u8 *)mask_pattern?

> @@ -3454,7 +3453,7 @@ static const struct ethtool_ops velocity_ethtool_ops = {
>  	.set_wol	=	velocity_ethtool_set_wol,
>  	.get_msglevel	=	velocity_get_msglevel,
>  	.set_msglevel	=	velocity_set_msglevel,
> -	.set_sg 	=	ethtool_op_set_sg,
> +	.set_sg	=	ethtool_op_set_sg,

bad alignment?


