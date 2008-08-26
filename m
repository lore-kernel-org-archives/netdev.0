From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-17
Date: Tue, 26 Aug 2008 22:19:25 +0800
Message-ID: <48B410ED.9060807@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53409 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757243AbYHZOVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:53 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 136220b..6a89852 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -134,7 +134,7 @@ static inline void wv_16_on(unsigned long ioaddr, u16 hacr)
  */
 static inline void wv_ints_off(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	
 	lp->hacr &= ~HACR_INTRON;
@@ -148,7 +148,7 @@ static inline void wv_ints_off(struct net_device * dev)
  */
 static inline void wv_ints_on(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 	lp->hacr |= HACR_INTRON;
@@ -526,7 +526,7 @@ static inline void obram_write(unsigned long ioaddr, u16 o, u8 * b, int n)
  */
 static void wv_ack(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cs;
 	int i;
@@ -568,7 +568,7 @@ static void wv_ack(struct net_device * dev)
  */
 static int wv_synchronous_cmd(struct net_device * dev, const char *str)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cmd;
 	ach_t cb;
@@ -824,7 +824,7 @@ if (lp->tx_n_in_use > 0)
  */
 static void wv_82586_reconfig(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Arm the flag, will be cleard in wv_82586_config() */
@@ -927,7 +927,7 @@ static void wv_psa_show(psa_t * p)
 static void wv_mmc_show(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	mmr_t m;
 
 	/* Basic check */
@@ -1107,8 +1107,6 @@ static void wv_scb_show(unsigned long ioaddr)
  */
 static void wv_ru_show(struct net_device * dev)
 {
-	/* net_local *lp = (net_local *) dev->priv; */
-
 	printk(KERN_DEBUG
 	       "##### WaveLAN i82586 receiver unit status: #####\n");
 	printk(KERN_DEBUG "ru:");
@@ -1153,7 +1151,7 @@ static void wv_cu_show_one(struct net_device * dev, net_local * lp, int i, u16 p
  */
 static void wv_cu_show(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned int i;
 	u16 p;
 
@@ -1195,7 +1193,7 @@ static void wv_local_show(struct net_device * dev)
 {
 	net_local *lp;
 
-	lp = (net_local *) dev->priv;
+	lp = netdev_priv(dev);
 
 	printk(KERN_DEBUG "local:");
 	printk(" tx_n_in_use=%d,", lp->tx_n_in_use);
@@ -1256,7 +1254,7 @@ static inline void wv_packet_info(u8 * p,	/* Packet to dump */
 static void wv_init_info(struct net_device * dev)
 {
 	short ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	psa_t psa;
 #ifdef DEBUG_BASIC_SHOW
 	DECLARE_MAC_BUF(mac);
@@ -1369,7 +1367,7 @@ static en_stats *wavelan_get_stats(struct net_device * dev)
 	printk(KERN_DEBUG "%s: <>wavelan_get_stats()\n", dev->name);
 #endif
 
-	return (&((net_local *) dev->priv)->stats);
+	return &((net_local *)netdev_priv(dev))->stats;
 }
 
 /*------------------------------------------------------------------*/
@@ -1382,7 +1380,7 @@ static en_stats *wavelan_get_stats(struct net_device * dev)
  */
 static void wavelan_set_multicast_list(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 
 #ifdef DEBUG_IOCTL_TRACE
 	printk(KERN_DEBUG "%s: ->wavelan_set_multicast_list()\n",
@@ -1716,7 +1714,7 @@ static inline void wl_spy_gather(struct net_device * dev,
  */
 static inline void wl_his_gather(struct net_device * dev, u8 * stats)
 {				/* Statistics to gather */
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	u8 level = stats[0] & MMR_SIGNAL_LVL;
 	int i;
 
@@ -1753,7 +1751,7 @@ static int wavelan_set_nwid(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	mm_t m;
 	unsigned long flags;
@@ -1812,7 +1810,7 @@ static int wavelan_get_nwid(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1844,7 +1842,7 @@ static int wavelan_set_freq(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	unsigned long flags;
 	int ret;
 
@@ -1874,7 +1872,7 @@ static int wavelan_get_freq(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1920,7 +1918,7 @@ static int wavelan_set_sens(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1956,7 +1954,7 @@ static int wavelan_get_sens(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1987,7 +1985,7 @@ static int wavelan_set_encode(struct net_device *dev,
 			      char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	unsigned long flags;
 	psa_t psa;
 	int ret = 0;
@@ -2057,7 +2055,7 @@ static int wavelan_get_encode(struct net_device *dev,
 			      char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -2104,7 +2102,7 @@ static int wavelan_get_range(struct net_device *dev,
 			     char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	struct iw_range *range = (struct iw_range *) extra;
 	unsigned long flags;
 	int ret = 0;
@@ -2179,7 +2177,7 @@ static int wavelan_set_qthr(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 
@@ -2211,7 +2209,7 @@ static int wavelan_get_qthr(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 
@@ -2239,7 +2237,7 @@ static int wavelan_set_histo(struct net_device *dev,
 			     union iwreq_data *wrqu,
 			     char *extra)
 {
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 
 	/* Check the number of intervals. */
 	if (wrqu->data.length > 16) {
@@ -2282,7 +2280,7 @@ static int wavelan_get_histo(struct net_device *dev,
 			     union iwreq_data *wrqu,
 			     char *extra)
 {
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 
 	/* Set the number of intervals. */
 	wrqu->data.length = lp->his_number;
@@ -2386,7 +2384,7 @@ static const struct iw_handler_def	wavelan_handler_def =
 static iw_stats *wavelan_get_wireless_stats(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	mmr_t m;
 	iw_stats *wstats;
 	unsigned long flags;
@@ -2461,7 +2459,7 @@ static iw_stats *wavelan_get_wireless_stats(struct net_device * dev)
 static void
 wv_packet_read(struct net_device * dev, u16 buf_off, int sksize)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	struct sk_buff *skb;
 
@@ -2556,7 +2554,7 @@ wv_packet_read(struct net_device * dev, u16 buf_off, int sksize)
 static void wv_receive(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	fd_t fd;
 	rbd_t rbd;
 	int nreaped = 0;
@@ -2738,7 +2736,7 @@ static void wv_receive(struct net_device * dev)
  */
 static int wv_packet_write(struct net_device * dev, void *buf, short length)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned short txblock;
 	unsigned short txpred;
@@ -2869,7 +2867,7 @@ static int wv_packet_write(struct net_device * dev, void *buf, short length)
  */
 static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 	char data[ETH_ZLEN];
 
@@ -2937,7 +2935,7 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 static int wv_mmc_init(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	psa_t psa;
 	mmw_t m;
 	int configured;
@@ -3108,7 +3106,7 @@ static int wv_mmc_init(struct net_device * dev)
  */
 static int wv_ru_start(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cs;
 	fd_t fd;
@@ -3200,7 +3198,7 @@ static int wv_ru_start(struct net_device * dev)
  */
 static int wv_cu_start(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	int i;
 	u16 txblock;
@@ -3301,7 +3299,7 @@ static int wv_cu_start(struct net_device * dev)
  */
 static int wv_82586_start(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	scp_t scp;		/* system configuration pointer */
 	iscp_t iscp;		/* intermediate scp */
@@ -3433,7 +3431,7 @@ static int wv_82586_start(struct net_device * dev)
  */
 static void wv_82586_config(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned short txblock;
 	unsigned short txpred;
@@ -3613,7 +3611,7 @@ static void wv_82586_config(struct net_device * dev)
  */
 static void wv_82586_stop(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cmd;
 
@@ -3650,7 +3648,7 @@ static void wv_82586_stop(struct net_device * dev)
  */
 static int wv_hw_reset(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 #ifdef DEBUG_CONFIG_TRACE
@@ -3751,7 +3749,7 @@ static irqreturn_t wavelan_interrupt(int irq, void *dev_id)
 	printk(KERN_DEBUG "%s: ->wavelan_interrupt()\n", dev->name);
 #endif
 
-	lp = (net_local *) dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 #ifdef DEBUG_INTERRUPT_INFO
@@ -3894,7 +3892,7 @@ static irqreturn_t wavelan_interrupt(int irq, void *dev_id)
  */
 static void wavelan_watchdog(struct net_device *	dev)
 {
-	net_local *	lp = (net_local *)dev->priv;
+	net_local *lp = netdev_priv(dev);
 	u_long		ioaddr = dev->base_addr;
 	unsigned long	flags;
 	unsigned int	nreaped;
@@ -3974,7 +3972,7 @@ static void wavelan_watchdog(struct net_device *	dev)
  */
 static int wavelan_open(struct net_device * dev)
 {
-	net_local *	lp = (net_local *)dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long	flags;
 
 #ifdef DEBUG_CALLBACK_TRACE
@@ -4029,7 +4027,7 @@ static int wavelan_open(struct net_device * dev)
  */
 static int wavelan_close(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 #ifdef DEBUG_CALLBACK_TRACE
@@ -4128,8 +4126,8 @@ static int __init wavelan_config(struct net_device *dev, unsigned short ioaddr)
 	dev->if_port = 0;
 
 	/* Initialize device structures */
-	memset(dev->priv, 0, sizeof(net_local));
-	lp = (net_local *) dev->priv;
+	memset(netdev_priv(dev), 0, sizeof(net_local));
+	lp = netdev_priv(dev);
 
 	/* Back link to the device structure. */
 	lp->dev = dev;


