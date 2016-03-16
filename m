From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 3/5] net: macb: Address checkpatch 'check' suggestions
Date: Wed, 16 Mar 2016 14:46:46 +0100
Message-ID: <56E963C6.3040404@atmel.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-4-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:14486 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964787AbcCPNqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:46:40 -0400
In-Reply-To: <1457896247-25934-4-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/03/2016 20:10, Moritz Fischer a =E9crit :
> This commit deals with a bunch of checkpatch suggestions
> that without changing behavior make checkpatch happier.
>=20
> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c | 46 +++++++++++++++++++--------=
----------
>  1 file changed, 24 insertions(+), 22 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index c2d31c5..53400f6 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -184,7 +184,7 @@ static void macb_get_hwaddr(struct macb *bp)
> =20
>  	pdata =3D dev_get_platdata(&bp->pdev->dev);
> =20
> -	/* Check all 4 address register for vaild address */
> +	/* Check all 4 address register for valid address */
>  	for (i =3D 0; i < 4; i++) {
>  		bottom =3D macb_or_gem_readl(bp, SA1B + i * 8);
>  		top =3D macb_or_gem_readl(bp, SA1T + i * 8);
> @@ -292,7 +292,7 @@ static void macb_set_tx_clk(struct clk *clk, int =
speed, struct net_device *dev)
>  	ferr =3D DIV_ROUND_UP(ferr, rate / 100000);
>  	if (ferr > 5)
>  		netdev_warn(dev, "unable to generate target frequency: %ld Hz\n",
> -				rate);
> +			    rate);
> =20
>  	if (clk_set_rate(clk, rate_rounded))
>  		netdev_err(dev, "adjusting tx_clk failed.\n");
> @@ -426,7 +426,7 @@ static int macb_mii_init(struct macb *bp)
>  	macb_writel(bp, NCR, MACB_BIT(MPE));
> =20
>  	bp->mii_bus =3D mdiobus_alloc();
> -	if (bp->mii_bus =3D=3D NULL) {
> +	if (!bp->mii_bus) {
>  		err =3D -ENOMEM;
>  		goto err_out;
>  	}
> @@ -435,7 +435,7 @@ static int macb_mii_init(struct macb *bp)
>  	bp->mii_bus->read =3D &macb_mdio_read;
>  	bp->mii_bus->write =3D &macb_mdio_write;
>  	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
> -		bp->pdev->name, bp->pdev->id);
> +		 bp->pdev->name, bp->pdev->id);
>  	bp->mii_bus->priv =3D bp;
>  	bp->mii_bus->parent =3D &bp->dev->dev;
>  	pdata =3D dev_get_platdata(&bp->pdev->dev);
> @@ -656,7 +656,7 @@ static void macb_tx_interrupt(struct macb_queue *=
queue)
>  		queue_writel(queue, ISR, MACB_BIT(TCOMP));
> =20
>  	netdev_vdbg(bp->dev, "macb_tx_interrupt status =3D 0x%03lx\n",
> -		(unsigned long)status);
> +		    (unsigned long)status);
> =20
>  	head =3D queue->tx_head;
>  	for (tail =3D queue->tx_tail; tail !=3D head; tail++) {
> @@ -725,10 +725,10 @@ static void gem_rx_refill(struct macb *bp)
> =20
>  		bp->rx_prepared_head++;
> =20
> -		if (bp->rx_skbuff[entry] =3D=3D NULL) {
> +		if (!bp->rx_skbuff[entry]) {
>  			/* allocate sk_buff for this free entry in ring */
>  			skb =3D netdev_alloc_skb(bp->dev, bp->rx_buffer_size);
> -			if (unlikely(skb =3D=3D NULL)) {
> +			if (unlikely(!skb)) {
>  				netdev_err(bp->dev,
>  					   "Unable to allocate sk_buff\n");
>  				break;
> @@ -762,7 +762,7 @@ static void gem_rx_refill(struct macb *bp)
>  	wmb();
> =20
>  	netdev_vdbg(bp->dev, "rx ring: prepared head %d, tail %d\n",
> -		   bp->rx_prepared_head, bp->rx_tail);
> +		    bp->rx_prepared_head, bp->rx_tail);
>  }
> =20
>  /* Mark DMA descriptors from begin up to and not including end as un=
used */
> @@ -876,8 +876,8 @@ static int macb_rx_frame(struct macb *bp, unsigne=
d int first_frag,
>  	len =3D desc->ctrl & bp->rx_frm_len_mask;
> =20
>  	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
> -		macb_rx_ring_wrap(first_frag),
> -		macb_rx_ring_wrap(last_frag), len);
> +		    macb_rx_ring_wrap(first_frag),
> +		    macb_rx_ring_wrap(last_frag), len);
> =20
>  	/* The ethernet header starts NET_IP_ALIGN bytes into the
>  	 * first buffer. Since the header is 14 bytes, this makes the
> @@ -916,7 +916,8 @@ static int macb_rx_frame(struct macb *bp, unsigne=
d int first_frag,
>  			frag_len =3D len - offset;
>  		}
>  		skb_copy_to_linear_data_offset(skb, offset,
> -				macb_rx_buffer(bp, frag), frag_len);
> +					       macb_rx_buffer(bp, frag),
> +					       frag_len);
>  		offset +=3D bp->rx_buffer_size;
>  		desc =3D macb_rx_desc(bp, frag);
>  		desc->addr &=3D ~MACB_BIT(RX_USED);
> @@ -934,7 +935,7 @@ static int macb_rx_frame(struct macb *bp, unsigne=
d int first_frag,
>  	bp->stats.rx_packets++;
>  	bp->stats.rx_bytes +=3D skb->len;
>  	netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
> -		   skb->len, skb->csum);
> +		    skb->len, skb->csum);
>  	netif_receive_skb(skb);
> =20
>  	return 0;
> @@ -999,7 +1000,7 @@ static int macb_poll(struct napi_struct *napi, i=
nt budget)
>  	work_done =3D 0;
> =20
>  	netdev_vdbg(bp->dev, "poll: status =3D %08lx, budget =3D %d\n",
> -		   (unsigned long)status, budget);
> +		    (unsigned long)status, budget);
> =20
>  	work_done =3D bp->macbgem_ops.mog_rx(bp, budget);
>  	if (work_done < budget) {
> @@ -1214,7 +1215,7 @@ static unsigned int macb_tx_map(struct macb *bp=
,
>  	}
> =20
>  	/* Should never happen */
> -	if (unlikely(tx_skb =3D=3D NULL)) {
> +	if (unlikely(!tx_skb)) {
>  		netdev_err(bp->dev, "BUG! empty skb!\n");
>  		return 0;
>  	}
> @@ -1284,16 +1285,16 @@ static int macb_start_xmit(struct sk_buff *sk=
b, struct net_device *dev)
> =20
>  #if defined(DEBUG) && defined(VERBOSE_DEBUG)
>  	netdev_vdbg(bp->dev,
> -		   "start_xmit: queue %hu len %u head %p data %p tail %p end %p\n"=
,
> -		   queue_index, skb->len, skb->head, skb->data,
> -		   skb_tail_pointer(skb), skb_end_pointer(skb));
> +		    "start_xmit: queue %hu len %u head %p data %p tail %p end %p\n=
",
> +		    queue_index, skb->len, skb->head, skb->data,
> +		    skb_tail_pointer(skb), skb_end_pointer(skb));
>  	print_hex_dump(KERN_DEBUG, "data: ", DUMP_PREFIX_OFFSET, 16, 1,
>  		       skb->data, 16, true);
>  #endif
> =20
>  	/* Count how many TX buffer descriptors are needed to send this
>  	 * socket buffer: skb fragments of jumbo frames may need to be
> -	 * splitted into many buffer descriptors.
> +	 * split into many buffer descriptors.
>  	 */
>  	count =3D DIV_ROUND_UP(skb_headlen(skb), bp->max_tx_length);
>  	nr_frags =3D skb_shinfo(skb)->nr_frags;
> @@ -1344,8 +1345,8 @@ static void macb_init_rx_buffer_size(struct mac=
b *bp, size_t size)
> =20
>  		if (bp->rx_buffer_size % RX_BUFFER_MULTIPLE) {
>  			netdev_dbg(bp->dev,
> -				    "RX buffer must be multiple of %d bytes, expanding\n",
> -				    RX_BUFFER_MULTIPLE);
> +				   "RX buffer must be multiple of %d bytes, expanding\n",
> +				   RX_BUFFER_MULTIPLE);
>  			bp->rx_buffer_size =3D
>  				roundup(bp->rx_buffer_size, RX_BUFFER_MULTIPLE);
>  		}
> @@ -1368,7 +1369,7 @@ static void gem_free_rx_buffers(struct macb *bp=
)
>  	for (i =3D 0; i < RX_RING_SIZE; i++) {
>  		skb =3D bp->rx_skbuff[i];
> =20
> -		if (skb =3D=3D NULL)
> +		if (!skb)
>  			continue;
> =20
>  		desc =3D &bp->rx_ring[i];
> @@ -1776,7 +1777,8 @@ static void macb_sethashtable(struct net_device=
 *dev)
>  	unsigned int bitnr;
>  	struct macb *bp =3D netdev_priv(dev);
> =20
> -	mc_filter[0] =3D mc_filter[1] =3D 0;
> +	mc_filter[0] =3D 0;
> +	mc_filter[1] =3D 0;
> =20
>  	netdev_for_each_mc_addr(ha, dev) {
>  		bitnr =3D hash_get_index(ha->addr);
>=20


--=20
Nicolas Ferre
