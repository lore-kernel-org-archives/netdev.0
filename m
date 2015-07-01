From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with
 NET_IP_ALIGN
Date: Wed, 01 Jul 2015 12:56:31 +0200
Message-ID: <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5592D105.7080006@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Nicolas Ferre <nicolas.ferre@atmel.com>
To: Nicolae Rosia <nicolae.rosia@certsign.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36317 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbbGAK4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 06:56:34 -0400
Received: by widjy10 with SMTP id jy10so54143595wid.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 03:56:33 -0700 (PDT)
In-Reply-To: <5592D105.7080006@certsign.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-30 at 20:25 +0300, Nicolae Rosia wrote:
> Signed-off-by: Nicolae Rosia <nicolae.rosia@certsign.ro>
> ---
>  drivers/net/ethernet/cadence/macb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index caeb395..dbb5160 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2554,9 +2554,9 @@ static void at91ether_rx(struct net_device *dev)
>  	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
>  		p_recv = lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
>  		pktlen = MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
> -		skb = netdev_alloc_skb(dev, pktlen + 2);
> +		skb = netdev_alloc_skb(dev, pktlen + NET_IP_ALIGN);
>  		if (skb) {
> -			skb_reserve(skb, 2);
> +			skb_reserve(skb, NET_IP_ALIGN);
>  			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
>  
>  			skb->protocol = eth_type_trans(skb, dev);

Then please use netdev_alloc_skb_ip_align(), so that you get rid of
skb_reserve()
