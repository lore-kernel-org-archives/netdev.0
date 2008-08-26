From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-10
Date: Tue, 26 Aug 2008 15:48:59 +0100
Message-ID: <20080826144858.GD7908@solarflare.com>
References: <48B3D717.7070706@cn.fujitsu.com> <48B410D4.2010105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48329 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755085AbYHZOtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 10:49:08 -0400
Content-Disposition: inline
In-Reply-To: <48B410D4.2010105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

I already made the same changes to sfc but was saving them for a patch
series.

Ben.

> ---
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index 45c72ee..4253980 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -1249,7 +1249,7 @@ static void efx_monitor(struct work_struct *data)
>   */
>  static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	EFX_ASSERT_RESET_SERIALISED(efx);
>  
> @@ -1303,7 +1303,7 @@ static void efx_fini_napi(struct efx_nic *efx)
>   */
>  static void efx_netpoll(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_channel *channel;
>  
>  	efx_for_each_channel_with_interrupt(channel, efx)
> @@ -1321,7 +1321,7 @@ static void efx_netpoll(struct net_device *net_dev)
>  /* Context: process, rtnl_lock() held. */
>  static int efx_net_open(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	EFX_ASSERT_RESET_SERIALISED(efx);
>  
>  	EFX_LOG(efx, "opening device %s on CPU %d\n", net_dev->name,
> @@ -1337,7 +1337,7 @@ static int efx_net_open(struct net_device *net_dev)
>   */
>  static int efx_net_stop(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	int rc;
>  
>  	EFX_LOG(efx, "closing %s on CPU %d\n", net_dev->name,
> @@ -1356,7 +1356,7 @@ static int efx_net_stop(struct net_device *net_dev)
>  /* Context: process, dev_base_lock or RTNL held, non-blocking. */
>  static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_mac_stats *mac_stats = &efx->mac_stats;
>  	struct net_device_stats *stats = &net_dev->stats;
>  
> @@ -1403,7 +1403,7 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
>  /* Context: netif_tx_lock held, BHs disabled. */
>  static void efx_watchdog(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d: %s\n",
>  		atomic_read(&efx->netif_stop_count), efx->port_enabled,
> @@ -1417,7 +1417,7 @@ static void efx_watchdog(struct net_device *net_dev)
>  /* Context: process, rtnl_lock() held. */
>  static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	int rc = 0;
>  
>  	EFX_ASSERT_RESET_SERIALISED(efx);
> @@ -1445,7 +1445,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
>  
>  static int efx_set_mac_address(struct net_device *net_dev, void *data)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct sockaddr *addr = data;
>  	char *new_addr = addr->sa_data;
>  
> @@ -1469,7 +1469,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
>  /* Context: netif_tx_lock held, BHs disabled. */
>  static void efx_set_multicast_list(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct dev_mc_list *mc_list = net_dev->mc_list;
>  	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
>  	int promiscuous;
> @@ -1510,7 +1510,7 @@ static int efx_netdev_event(struct notifier_block *this,
>  	struct net_device *net_dev = ptr;
>  
>  	if (net_dev->open == efx_net_open && event == NETDEV_CHANGENAME) {
> -		struct efx_nic *efx = net_dev->priv;
> +		struct efx_nic *efx = netdev_priv(net_dev);
>  
>  		strcpy(efx->name, net_dev->name);
>  	}
> @@ -1568,7 +1568,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
>  	if (!efx->net_dev)
>  		return;
>  
> -	BUG_ON(efx->net_dev->priv != efx);
> +	BUG_ON(netdev_priv(efx->net_dev) != efx);
>  
>  	/* Free up any skbs still remaining. This has to happen before
>  	 * we try to unregister the netdev as running their destructors
> @@ -2105,7 +2105,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
>  			      NETIF_F_HIGHDMA | NETIF_F_TSO);
>  	if (lro)
>  		net_dev->features |= NETIF_F_LRO;
> -	efx = net_dev->priv;
> +	efx = netdev_priv(net_dev);
>  	pci_set_drvdata(pci_dev, efx);
>  	rc = efx_init_struct(efx, type, pci_dev, net_dev);
>  	if (rc)
> diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
> index e2c75d1..8a15be6 100644
> --- a/drivers/net/sfc/ethtool.c
> +++ b/drivers/net/sfc/ethtool.c
> @@ -183,7 +183,7 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
>  /* Identify device by flashing LEDs */
>  static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	efx->board_info.blink(efx, 1);
>  	schedule_timeout_interruptible(seconds * HZ);
> @@ -195,7 +195,7 @@ static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds)
>  int efx_ethtool_get_settings(struct net_device *net_dev,
>  			     struct ethtool_cmd *ecmd)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	int rc;
>  
>  	mutex_lock(&efx->mac_lock);
> @@ -209,7 +209,7 @@ int efx_ethtool_get_settings(struct net_device *net_dev,
>  int efx_ethtool_set_settings(struct net_device *net_dev,
>  			     struct ethtool_cmd *ecmd)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	int rc;
>  
>  	mutex_lock(&efx->mac_lock);
> @@ -224,7 +224,7 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
>  static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
>  				    struct ethtool_drvinfo *info)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	strlcpy(info->driver, EFX_DRIVER_NAME, sizeof(info->driver));
>  	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
> @@ -376,7 +376,7 @@ static int efx_ethtool_get_stats_count(struct net_device *net_dev)
>  
>  static int efx_ethtool_self_test_count(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
>  }
> @@ -384,7 +384,7 @@ static int efx_ethtool_self_test_count(struct net_device *net_dev)
>  static void efx_ethtool_get_strings(struct net_device *net_dev,
>  				    u32 string_set, u8 *strings)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct ethtool_string *ethtool_strings =
>  		(struct ethtool_string *)strings;
>  	int i;
> @@ -410,7 +410,7 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
>  				  struct ethtool_stats *stats,
>  				  u64 *data)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_mac_stats *mac_stats = &efx->mac_stats;
>  	struct efx_ethtool_stat *stat;
>  	struct efx_channel *channel;
> @@ -460,7 +460,7 @@ static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
>  
>  static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	int rc;
>  
>  	rc = ethtool_op_set_tx_csum(net_dev, enable);
> @@ -483,7 +483,7 @@ static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
>  
>  static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	/* No way to stop the hardware doing the checks; we just
>  	 * ignore the result.
> @@ -495,7 +495,7 @@ static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
>  
>  static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	return efx->rx_checksum_enabled;
>  }
> @@ -503,7 +503,7 @@ static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
>  static void efx_ethtool_self_test(struct net_device *net_dev,
>  				  struct ethtool_test *test, u64 *data)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_self_tests efx_tests;
>  	int offline, already_up;
>  	int rc;
> @@ -561,14 +561,14 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
>  /* Restart autonegotiation */
>  static int efx_ethtool_nway_reset(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	return mii_nway_restart(&efx->mii);
>  }
>  
>  static u32 efx_ethtool_get_link(struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	return efx->link_up;
>  }
> @@ -576,7 +576,7 @@ static u32 efx_ethtool_get_link(struct net_device *net_dev)
>  static int efx_ethtool_get_coalesce(struct net_device *net_dev,
>  				    struct ethtool_coalesce *coalesce)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_tx_queue *tx_queue;
>  	struct efx_rx_queue *rx_queue;
>  	struct efx_channel *channel;
> @@ -614,7 +614,7 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
>  static int efx_ethtool_set_coalesce(struct net_device *net_dev,
>  				    struct ethtool_coalesce *coalesce)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	struct efx_channel *channel;
>  	struct efx_tx_queue *tx_queue;
>  	unsigned tx_usecs, rx_usecs;
> @@ -657,7 +657,7 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
>  static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
>  				      struct ethtool_pauseparam *pause)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	enum efx_fc_type flow_control = efx->flow_control;
>  	int rc;
>  
> @@ -680,7 +680,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
>  static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
>  				       struct ethtool_pauseparam *pause)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  
>  	pause->rx_pause = (efx->flow_control & EFX_FC_RX) ? 1 : 0;
>  	pause->tx_pause = (efx->flow_control & EFX_FC_TX) ? 1 : 0;
> diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> index 9138ee5..c7aa2f6 100644
> --- a/drivers/net/sfc/falcon.c
> +++ b/drivers/net/sfc/falcon.c
> @@ -1951,7 +1951,7 @@ static int falcon_gmii_wait(struct efx_nic *efx)
>  static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
>  			      int addr, int value)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	unsigned int phy_id2 = phy_id & FALCON_PHY_ID_ID_MASK;
>  	efx_oword_t reg;
>  
> @@ -2019,7 +2019,7 @@ static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
>   * could be read, -1 will be returned. */
>  static int falcon_mdio_read(struct net_device *net_dev, int phy_id, int addr)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	unsigned int phy_addr = phy_id & FALCON_PHY_ID_ID_MASK;
>  	efx_oword_t reg;
>  	int value = -1;
> diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
> index 5e8374a..2a09101 100644
> --- a/drivers/net/sfc/tx.c
> +++ b/drivers/net/sfc/tx.c
> @@ -367,7 +367,7 @@ inline int efx_xmit(struct efx_nic *efx,
>   */
>  int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
>  {
> -	struct efx_nic *efx = net_dev->priv;
> +	struct efx_nic *efx = netdev_priv(net_dev);
>  	return efx_xmit(efx, &efx->tx_queue[0], skb);
>  }
>  

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
