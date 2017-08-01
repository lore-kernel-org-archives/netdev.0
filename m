From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v6 net-next] net: systemport: Support 64bit statistics
Date: Tue, 1 Aug 2017 09:53:30 -0700
Message-ID: <8bc9b261-d2bc-f548-3bb5-7d1646a88f26@gmail.com>
References: <1501550293-20443-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: "Jianming.qiao" <jqiaoulk@gmail.com>, davem@davemloft.net,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35593 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdHAQxe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 12:53:34 -0400
Received: by mail-qt0-f196.google.com with SMTP id t37so2137218qtg.2
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 09:53:33 -0700 (PDT)
In-Reply-To: <1501550293-20443-1-git-send-email-jqiaoulk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2017 06:18 PM, Jianming.qiao wrote:
> When using Broadcom Systemport device in 32bit Platform, ifconfig can
> only report up to 4G tx,rx status, which will be wrapped to 0 when the
> number of incoming or outgoing packets exceeds 4G, only taking
> around 2 hours in busy network environment (such as streaming).
> Therefore, it makes hard for network diagnostic tool to get reliable
> statistical result, so the patch is used to add 64bit support for
> Broadcom Systemport device in 32bit Platform.

Almost there, can you turn on lock debugging and try to e.g: modprobe
bcmsysport:

<4>[   17.836361] CPU: 3 PID: 1328 Comm: modprobe Not tainted
4.13.0-rc1-00560-g67f9849fc4f9 #300
<4>[   17.844760] Hardware name: Broadcom STB (Flattened Device Tree)
<4>[   17.850744] [<c0211fe4>] (unwind_backtrace) from [<c020cc4c>]
(show_stack+0x10/0x14)
<4>[   17.858555] [<c020cc4c>] (show_stack) from [<c0a3204c>]
(dump_stack+0xb0/0xdc)
<4>[   17.865838] [<c0a3204c>] (dump_stack) from [<c0277564>]
(register_lock_class+0x200/0x5ec)
<4>[   17.874075] [<c0277564>] (register_lock_class) from [<c027b7f0>]
(__lock_acquire+0x9c/0x19c4)
<4>[   17.882664] [<c027b7f0>] (__lock_acquire) from [<c027dc24>]
(lock_acquire+0xd0/0x294)
<4>[   17.890594] [<c027dc24>] (lock_acquire) from [<bf021ee8>]
(bcm_sysport_get_stats64+0xe0/0x1b4 [bcmsysport])
<4>[   17.900440] [<bf021ee8>] (bcm_sysport_get_stats64 [bcmsysport])
from [<c08c492c>] (dev_get_stats+0x38/0xac)
<4>[   17.910263] [<c08c492c>] (dev_get_stats) from [<c08e94cc>]
(rtnl_fill_stats+0x38/0x118)
<4>[   17.918330] [<c08e94cc>] (rtnl_fill_stats) from [<c08e44ec>]
(rtnl_fill_ifinfo+0x4cc/0xdac)
<4>[   17.926749] [<c08e44ec>] (rtnl_fill_ifinfo) from [<c08e8d5c>]
(rtmsg_ifinfo_build_skb+0x70/0xdc)
<4>[   17.935591] [<c08e8d5c>] (rtmsg_ifinfo_build_skb) from
[<c08e8ddc>] (rtmsg_ifinfo_event.part.6+0x14/0x44)
<4>[   17.945221] [<c08e8ddc>] (rtmsg_ifinfo_event.part.6) from
[<c08e8e2c>] (rtmsg_ifinfo+0x20/0x28)
<4>[   17.953990] [<c08e8e2c>] (rtmsg_ifinfo) from [<c08d3b04>]
(register_netdevice+0x558/0x684)
<4>[   17.962311] [<c08d3b04>] (register_netdevice) from [<c08d3c44>]
(register_netdev+0x14/0x24)
<4>[   17.970739] [<c08d3c44>] (register_netdev) from [<bf02310c>]
(bcm_sysport_probe+0x2f0/0x42c [bcmsysport])
<4>[   17.980384] [<bf02310c>] (bcm_sysport_probe [bcmsysport]) from
[<c0698680>] (platform_drv_probe+0x4c/0xac)
<4>[   17.990100] [<c0698680>] (platform_drv_probe) from [<c06961b8>]
(driver_probe_device+0x2b8/0x468)
<4>[   17.999030] [<c06961b8>] (driver_probe_device) from [<c0696454>]
(__driver_attach+0xec/0x128)
<4>[   18.007613] [<c0696454>] (__driver_attach) from [<c069413c>]
(bus_for_each_dev+0x74/0xb8)
<4>[   18.015844] [<c069413c>] (bus_for_each_dev) from [<c06954bc>]
(bus_add_driver+0x1bc/0x270)
<4>[   18.024158] [<c06954bc>] (bus_add_driver) from [<c06974c0>]
(driver_register+0x78/0xf8)
<4>[   18.032218] [<c06974c0>] (driver_register) from [<c0201908>]
(do_one_initcall+0x50/0x190)
<4>[   18.040446] [<c0201908>] (do_one_initcall) from [<c02cd8f8>]
(do_init_module+0x64/0x1f8)
<4>[   18.048584] [<c02cd8f8>] (do_init_module) from [<c02cc4ec>]
(load_module+0x1eb4/0x27f0)
<4>[   18.056641] [<c02cc4ec>] (load_module) from [<c02ccf50>]
(SyS_init_module+0x128/0x19c)
<4>[   18.064623] [<c02ccf50>] (SyS_init_module) from [<c02085a0>]
(ret_fast_syscall+0x0/0x1c)
<6>[   18.072890] brcm-systemport f04a0000.ethernet: Broadcom
SYSTEMPORTv 1.00 at 0xf0ca8000 (irqs: 64, 65, TXQs: 32, RXQs: 1)

You might also want to check the output of ethtool -S because now
tx_bytes and tx_packets is all zeroes.

I know we are not supposed to include netdev stats within ethtool, but
since it was done that way and ethtool is an user-facing/ABI, this needs
to keep working.

Thanks!

> 
> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 68 ++++++++++++++++++++----------
>  drivers/net/ethernet/broadcom/bcmsysport.h |  9 +++-
>  2 files changed, 52 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 5333601..bb3cc7a 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -662,6 +662,7 @@ static int bcm_sysport_alloc_rx_bufs(struct bcm_sysport_priv *priv)
>  static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>  					unsigned int budget)
>  {
> +	struct bcm_sysport_stats *stats64 = &priv->stats64;
>  	struct net_device *ndev = priv->netdev;
>  	unsigned int processed = 0, to_process;
>  	struct bcm_sysport_cb *cb;
> @@ -765,6 +766,10 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>  		skb->protocol = eth_type_trans(skb, ndev);
>  		ndev->stats.rx_packets++;
>  		ndev->stats.rx_bytes += len;
> +		u64_stats_update_begin(&stats64->syncp);
> +		stats64->rx_packets++;
> +		stats64->rx_bytes += len;
> +		u64_stats_update_end(&stats64->syncp);
>  
>  		napi_gro_receive(&priv->napi, skb);
>  next:
> @@ -787,17 +792,15 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
>  	struct device *kdev = &priv->pdev->dev;
>  
>  	if (cb->skb) {
> -		ring->bytes += cb->skb->len;
>  		*bytes_compl += cb->skb->len;
>  		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
>  				 dma_unmap_len(cb, dma_len),
>  				 DMA_TO_DEVICE);
> -		ring->packets++;
>  		(*pkts_compl)++;
>  		bcm_sysport_free_cb(cb);
>  	/* SKB fragment */
>  	} else if (dma_unmap_addr(cb, dma_addr)) {
> -		ring->bytes += dma_unmap_len(cb, dma_len);
> +		*bytes_compl += dma_unmap_len(cb, dma_len);
>  		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
>  			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
>  		dma_unmap_addr_set(cb, dma_addr, 0);
> @@ -808,9 +811,10 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
>  static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
>  					     struct bcm_sysport_tx_ring *ring)
>  {
> -	struct net_device *ndev = priv->netdev;
>  	unsigned int c_index, last_c_index, last_tx_cn, num_tx_cbs;
> +	struct bcm_sysport_stats *stats64 = &priv->stats64;
>  	unsigned int pkts_compl = 0, bytes_compl = 0;
> +	struct net_device *ndev = priv->netdev;
>  	struct bcm_sysport_cb *cb;
>  	u32 hw_ind;
>  
> @@ -849,6 +853,11 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
>  		last_c_index &= (num_tx_cbs - 1);
>  	}
>  
> +	u64_stats_update_begin(&stats64->syncp);
> +	ring->packets += pkts_compl;
> +	ring->bytes += bytes_compl;
> +	u64_stats_update_end(&stats64->syncp);
> +
>  	ring->c_index = c_index;
>  
>  	netif_dbg(priv, tx_done, ndev,
> @@ -1671,24 +1680,6 @@ static int bcm_sysport_change_mac(struct net_device *dev, void *p)
>  	return 0;
>  }
>  
> -static struct net_device_stats *bcm_sysport_get_nstats(struct net_device *dev)
> -{
> -	struct bcm_sysport_priv *priv = netdev_priv(dev);
> -	unsigned long tx_bytes = 0, tx_packets = 0;
> -	struct bcm_sysport_tx_ring *ring;
> -	unsigned int q;
> -
> -	for (q = 0; q < dev->num_tx_queues; q++) {
> -		ring = &priv->tx_rings[q];
> -		tx_bytes += ring->bytes;
> -		tx_packets += ring->packets;
> -	}
> -
> -	dev->stats.tx_bytes = tx_bytes;
> -	dev->stats.tx_packets = tx_packets;
> -	return &dev->stats;
> -}
> -
>  static void bcm_sysport_netif_start(struct net_device *dev)
>  {
>  	struct bcm_sysport_priv *priv = netdev_priv(dev);
> @@ -1923,6 +1914,37 @@ static int bcm_sysport_stop(struct net_device *dev)
>  	return 0;
>  }
>  
> +static void bcm_sysport_get_stats64(struct net_device *dev,
> +				    struct rtnl_link_stats64 *stats)
> +{
> +	struct bcm_sysport_priv *priv = netdev_priv(dev);
> +	struct bcm_sysport_stats *stats64 = &priv->stats64;
> +	struct bcm_sysport_tx_ring *ring;
> +	u64 tx_packets = 0, tx_bytes = 0;
> +	unsigned int start;
> +	unsigned int q;
> +
> +	netdev_stats_to_stats64(stats, &dev->stats);
> +
> +	for (q = 0; q < dev->num_tx_queues; q++) {
> +		ring = &priv->tx_rings[q];
> +		do {
> +			start = u64_stats_fetch_begin_irq(&stats64->syncp);
> +			tx_bytes = ring->bytes;
> +			tx_packets = ring->packets;
> +		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
> +
> +		stats->tx_bytes += tx_bytes;
> +		stats->tx_packets += tx_packets;
> +	}
> +
> +	do {
> +		start = u64_stats_fetch_begin_irq(&stats64->syncp);
> +		stats->rx_packets = stats64->rx_packets;
> +		stats->rx_bytes = stats64->rx_bytes;
> +	} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
> +}
> +
>  static const struct ethtool_ops bcm_sysport_ethtool_ops = {
>  	.get_drvinfo		= bcm_sysport_get_drvinfo,
>  	.get_msglevel		= bcm_sysport_get_msglvl,
> @@ -1950,7 +1972,7 @@ static int bcm_sysport_stop(struct net_device *dev)
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= bcm_sysport_poll_controller,
>  #endif
> -	.ndo_get_stats		= bcm_sysport_get_nstats,
> +	.ndo_get_stats64	= bcm_sysport_get_stats64,
>  };
>  
>  #define REV_FMT	"v%2x.%02x"
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
> index 77a51c1..c03a176 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.h
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.h
> @@ -657,6 +657,9 @@ struct bcm_sysport_stats {
>  	enum bcm_sysport_stat_type type;
>  	/* reg offset from UMAC base for misc counters */
>  	u16 reg_offset;
> +	u64     rx_packets;
> +	u64     rx_bytes;
> +	struct u64_stats_sync   syncp;
>  };
>  
>  /* Software house keeping helper structure */
> @@ -693,8 +696,8 @@ struct bcm_sysport_tx_ring {
>  	struct bcm_sysport_cb *cbs;	/* Transmit control blocks */
>  	struct dma_desc	*desc_cpu;	/* CPU view of the descriptor */
>  	struct bcm_sysport_priv *priv;	/* private context backpointer */
> -	unsigned long	packets;	/* packets statistics */
> -	unsigned long	bytes;		/* bytes statistics */
> +	u64	packets;		/* packets statistics */
> +	u64	bytes;			/* bytes statistics */
>  };
>  
>  /* Driver private structure */
> @@ -743,5 +746,7 @@ struct bcm_sysport_priv {
>  
>  	/* Ethtool */
>  	u32			msg_enable;
> +	/* 64bit stats on 32bit/64bit Machine */
> +	struct bcm_sysport_stats stats64;
>  };
>  #endif /* __BCM_SYSPORT_H */
> 


-- 
Florian
