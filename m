From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/wireless/ drivers
Date: Thu, 4 Mar 2004 13:20:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304132000.623fcda4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


| 
| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunlap <rddunlap@osdl.org>


--
~Randy



 linux-264-302-priv-rddunlap/drivers/net/wireless/atmel.c   |   72 ++++-----
 linux-264-302-priv-rddunlap/drivers/net/wireless/orinoco.c |  104 ++++++-------
 2 files changed, 88 insertions(+), 88 deletions(-)

diff -puN drivers/net/wireless/atmel.c~net_wireless_casts drivers/net/wireless/atmel.c
--- linux-264-302-priv/drivers/net/wireless/atmel.c~net_wireless_casts	2004-03-03 10:02:14.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wireless/atmel.c	2004-03-03 10:24:16.000000000 -0800
@@ -796,7 +796,7 @@ static void tx_update_descriptor(struct 
 
 static int start_tx (struct sk_buff *skb, struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *)dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	struct ieee802_11_hdr header;
 	unsigned long flags;
 	u16 buff, frame_ctl, len = (ETH_ZLEN < skb->len) ? skb->len : ETH_ZLEN;
@@ -1167,7 +1167,7 @@ static void reset_irq_status(struct atme
 static irqreturn_t service_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct atmel_private *priv = (struct atmel_private *) dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	u8 isr;
 	
 	if (priv->card && priv->present_callback && 
@@ -1234,13 +1234,13 @@ static irqreturn_t service_interrupt(int
 
 static struct net_device_stats *atmel_get_stats (struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *)dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	return &priv->stats;
 }
 
 static struct iw_statistics *atmel_get_wireless_stats (struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *)dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	/* update the link quality here in case we are seeing no beacons 
 	   at all to drive the process */
@@ -1287,7 +1287,7 @@ static int atmel_set_mac_address(struct 
 
 static int atmel_open (struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *) dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	priv->station_state = STATION_STATE_INITIALIZING;
 	if (!reset_atmel_card(dev)) {
 		priv->station_state = STATION_STATE_DOWN;
@@ -1298,7 +1298,7 @@ static int atmel_open (struct net_device
 
 static int atmel_close (struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *) dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 		
 	netif_carrier_off(dev);	
 	if (netif_running(dev))
@@ -1378,7 +1378,7 @@ static int atmel_proc_output (char *buf,
 static int atmel_read_proc(char *page, char **start, off_t off,
 			   int count, int *eof, void *data)
 {
-        struct atmel_private *priv = (struct atmel_private *)data;
+        struct atmel_private *priv = data;
 	int len = atmel_proc_output (page, priv);
         if (len <= off+count) *eof = 1;
         *start = page + off;
@@ -1406,7 +1406,7 @@ struct net_device *init_atmel_card( unsi
 		goto err_out_free;
 	}
 
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 	priv->dev = dev;
 	priv->sys_dev = sys_dev;
 	priv->present_callback = card_present;
@@ -1525,7 +1525,7 @@ EXPORT_SYMBOL(init_atmel_card);
 
 void stop_atmel_card(struct net_device *dev, int freeres)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 		
 	/* put a brick on it... */
 	if (priv->bus_type == BUS_TYPE_PCCARD) 
@@ -1582,7 +1582,7 @@ static int atmel_set_essid(struct net_de
 			   struct iw_point *dwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	/* Check if we asked for `any' */
 	if(dwrq->flags == 0) {
@@ -1610,7 +1610,7 @@ static int atmel_get_essid(struct net_de
 			   struct iw_point *dwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	/* Get the current SSID */
 	if (priv->SSID_size == 0) {
@@ -1633,7 +1633,7 @@ static int atmel_get_wap(struct net_devi
 			 struct sockaddr *awrq,
 			 char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	memcpy(awrq->sa_data, priv->CurrentBSSID, 6);
 	awrq->sa_family = ARPHRD_ETHER;
 
@@ -1645,7 +1645,7 @@ static int atmel_set_encode(struct net_d
 			    struct iw_point *dwrq,
 			    char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	/* Basic checking: do we have a key to set ?
 	 * Note : with the new API, it's impossible to get a NULL pointer.
@@ -1736,7 +1736,7 @@ static int atmel_get_encode(struct net_d
 			    struct iw_point *dwrq,
 			    char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 	
 	if (!priv->wep_is_on)
@@ -1776,7 +1776,7 @@ static int atmel_set_rate(struct net_dev
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	
 	if (vwrq->fixed == 0) {
 		priv->tx_rate = 3;
@@ -1808,7 +1808,7 @@ static int atmel_set_mode(struct net_dev
 			  __u32 *uwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	if (*uwrq != IW_MODE_ADHOC && *uwrq != IW_MODE_INFRA)
 		return -EINVAL;
@@ -1822,7 +1822,7 @@ static int atmel_get_mode(struct net_dev
 			  __u32 *uwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	
 	*uwrq = priv->operating_mode;
 	return 0;
@@ -1833,7 +1833,7 @@ static int atmel_get_rate(struct net_dev
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	if (priv->auto_tx_rate) {
 		vwrq->fixed = 0;
@@ -1855,7 +1855,7 @@ static int atmel_set_power(struct net_de
 			   struct iw_param *vwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	priv->power_mode = vwrq->disabled ? 0 : 1;
 	return -EINPROGRESS;
 }
@@ -1865,7 +1865,7 @@ static int atmel_get_power(struct net_de
 			   struct iw_param *vwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	vwrq->disabled = priv->power_mode ? 0 : 1;
 	vwrq->flags = IW_POWER_ON;
 	return 0;
@@ -1876,7 +1876,7 @@ static int atmel_set_retry(struct net_de
 			   struct iw_param *vwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	
 	if(!vwrq->disabled && (vwrq->flags & IW_RETRY_LIMIT)) {
 		if(vwrq->flags & IW_RETRY_MAX)
@@ -1899,7 +1899,7 @@ static int atmel_get_retry(struct net_de
 			   struct iw_param *vwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	vwrq->disabled = 0;      /* Can't be disabled */
 
@@ -1922,7 +1922,7 @@ static int atmel_set_rts(struct net_devi
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	int rthr = vwrq->value;
 
 	if(vwrq->disabled)
@@ -1940,7 +1940,7 @@ static int atmel_get_rts(struct net_devi
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	
 	vwrq->value = priv->rts_threshold;
 	vwrq->disabled = (vwrq->value >= 2347);
@@ -1954,7 +1954,7 @@ static int atmel_set_frag(struct net_dev
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	int fthr = vwrq->value;
 
 	if(vwrq->disabled)
@@ -1973,7 +1973,7 @@ static int atmel_get_frag(struct net_dev
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	vwrq->value = priv->frag_threshold;
 	vwrq->disabled = (vwrq->value >= 2346);
@@ -1990,7 +1990,7 @@ static int atmel_set_freq(struct net_dev
 			  struct iw_freq *fwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	int rc = -EINPROGRESS;		/* Call commit handler */
 	
 	/* If setting by frequency, convert to a channel */
@@ -2024,7 +2024,7 @@ static int atmel_get_freq(struct net_dev
 			  struct iw_freq *fwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	fwrq->m = priv->channel;
 	fwrq->e = 0;
@@ -2036,7 +2036,7 @@ static int atmel_set_scan(struct net_dev
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 
 	/* Note : you may have realised that, as this is a SET operation,
 	 * this is privileged and therefore a normal user can't
@@ -2074,7 +2074,7 @@ static int atmel_get_scan(struct net_dev
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	int i;
 	char *current_ev = extra;
 	struct iw_event	iwe;
@@ -2126,7 +2126,7 @@ static int atmel_get_range(struct net_de
 			   struct iw_point *dwrq,
 			   char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	struct iw_range *range = (struct iw_range *) extra;
 	int k,i,j;
 
@@ -2193,7 +2193,7 @@ static int atmel_set_wap(struct net_devi
 			 struct sockaddr *awrq,
 			 char *extra)
 {
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	int i;
 	static const u8 bcast[] = { 255, 255, 255, 255, 255, 255 };
 	
@@ -2318,7 +2318,7 @@ static const struct iw_handler_def	atmel
 static int atmel_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	int rc = 0;
-	struct atmel_private *priv = (struct atmel_private *) dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	atmel_priv_ioctl com;
 	struct iwreq *wrq = (struct iwreq *) rq;
 	unsigned char *new_firmware;
@@ -3053,7 +3053,7 @@ static void atmel_management_frame(struc
 static void atmel_management_timer(u_long a)
 {
   struct net_device *dev = (struct net_device *) a;
-  struct atmel_private *priv = (struct atmel_private *)dev->priv;
+  struct atmel_private *priv = netdev_priv(dev);
   unsigned long flags;
   
   /* Check if the card has been yanked. */
@@ -3297,7 +3297,7 @@ static int atmel_wakeup_firmware(struct 
 static int probe_atmel_card(struct net_device *dev)
 {
 	int rc = 0;
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	 
 	/* reset pccard */
 	if (priv->bus_type == BUS_TYPE_PCCARD) 
@@ -3486,7 +3486,7 @@ int reset_atmel_card(struct net_device *
 	   which is the route into the rest of the firmare datastructures. */
 
 	int channel;
-	struct atmel_private *priv = dev->priv;
+	struct atmel_private *priv = netdev_priv(dev);
 	u8 configuration;
 	
 	/* data to add to the firmware names, in priority order
diff -puN drivers/net/wireless/orinoco.c~net_wireless_casts drivers/net/wireless/orinoco.c
--- linux-264-302-priv/drivers/net/wireless/orinoco.c~net_wireless_casts	2004-03-03 10:02:14.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/wireless/orinoco.c	2004-03-03 10:27:06.000000000 -0800
@@ -599,7 +599,7 @@ static int orinoco_debug_dump_recs(struc
 
 int __orinoco_up(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct hermes *hw = &priv->hw;
 	int err;
 
@@ -626,7 +626,7 @@ int __orinoco_up(struct net_device *dev)
 
 int __orinoco_down(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct hermes *hw = &priv->hw;
 	int err;
 
@@ -657,7 +657,7 @@ int __orinoco_down(struct net_device *de
 
 int orinoco_reinit_firmware(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct hermes *hw = &priv->hw;
 	int err;
 
@@ -685,7 +685,7 @@ int orinoco_reinit_firmware(struct net_d
 
 static int orinoco_open(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	unsigned long flags;
 	int err;
 
@@ -705,7 +705,7 @@ static int orinoco_open(struct net_devic
 
 int orinoco_stop(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int err = 0;
 
 	/* We mustn't use orinoco_lock() here, because we need to be
@@ -724,7 +724,7 @@ int orinoco_stop(struct net_device *dev)
 
 static int __orinoco_program_rids(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err;
 	struct hermes_idstring idbuf;
@@ -912,7 +912,7 @@ ESSID in IBSS-Ad-Hoc mode.\n", dev->name
 /* xyzzy */
 static int orinoco_reconfigure(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct hermes *hw = &priv->hw;
 	unsigned long flags;
 	int err = 0;
@@ -965,7 +965,7 @@ static int orinoco_reconfigure(struct ne
  * schedule_work() */
 static void orinoco_reset(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct hermes *hw = &priv->hw;
 	int err;
 	unsigned long flags;
@@ -1070,7 +1070,7 @@ is_ethersnap(struct header_struct *hdr)
 static void
 orinoco_set_multicast_list(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	if (orinoco_lock(priv, &flags) != 0) {
@@ -1433,7 +1433,7 @@ static void show_rx_frame(struct orinoco
 irqreturn_t orinoco_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int count = MAX_IRQLOOPS_PER_IRQ;
 	u16 evstat, events;
@@ -1561,7 +1561,7 @@ static void print_linkstatus(struct net_
 
 static void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	u16 infofid;
 	struct {
 		u16 len;
@@ -1662,7 +1662,7 @@ static void __orinoco_ev_info(struct net
 
 static void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	struct iw_statistics *wstats = &priv->wstats;
 	struct sk_buff *skb = NULL;
@@ -1814,7 +1814,7 @@ static void __orinoco_ev_rx(struct net_d
 
 static void __orinoco_ev_txexc(struct net_device *dev, hermes_t *hw)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	u16 fid = hermes_read_regn(hw, TXCOMPLFID);
 	struct hermes_tx_descriptor desc;
@@ -1840,7 +1840,7 @@ static void __orinoco_ev_txexc(struct ne
 
 static void __orinoco_ev_tx(struct net_device *dev, hermes_t *hw)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 
 	stats->tx_packets++;
@@ -1850,7 +1850,7 @@ static void __orinoco_ev_tx(struct net_d
 
 static void __orinoco_ev_alloc(struct net_device *dev, hermes_t *hw)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 
 	u16 fid = hermes_read_regn(hw, ALLOCFID);
 
@@ -1886,7 +1886,7 @@ static int determine_firmware_type(struc
 
 static void determine_firmware(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err;
 	struct sta_id sta_id;
@@ -2024,7 +2024,7 @@ static void determine_firmware(struct ne
 static int
 orinoco_init(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err = 0;
 	struct hermes_idstring nickbuf;
@@ -2204,7 +2204,7 @@ orinoco_init(struct net_device *dev)
 struct net_device_stats *
 orinoco_get_stats(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	
 	return &priv->stats;
 }
@@ -2212,7 +2212,7 @@ orinoco_get_stats(struct net_device *dev
 struct iw_statistics *
 orinoco_get_wireless_stats(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	struct iw_statistics *wstats = &priv->wstats;
 	int err = 0;
@@ -2271,7 +2271,7 @@ orinoco_get_wireless_stats(struct net_de
 static inline void orinoco_spy_gather(struct net_device *dev, u_char *mac,
 				    int level, int noise)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int i;
 
 	/* Gather wireless spy statistics: for each packet, compare the
@@ -2290,7 +2290,7 @@ orinoco_stat_gather(struct net_device *d
 		    struct sk_buff *skb,
 		    struct hermes_rx_descriptor *desc)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 
 	/* Using spy support with lots of Rx packets, like in an
 	 * infrastructure (AP), will really slow down everything, because
@@ -2311,7 +2311,7 @@ orinoco_stat_gather(struct net_device *d
 static int
 orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	hermes_t *hw = &priv->hw;
 	int err = 0;
@@ -2449,7 +2449,7 @@ orinoco_xmit(struct sk_buff *skb, struct
 static void
 orinoco_tx_timeout(struct net_device *dev)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	struct hermes *hw = &priv->hw;
 
@@ -2466,7 +2466,7 @@ orinoco_tx_timeout(struct net_device *de
 static int
 orinoco_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 
 	if ( (new_mtu < ORINOCO_MIN_MTU) || (new_mtu > ORINOCO_MAX_MTU) )
 		return -EINVAL;
@@ -2484,7 +2484,7 @@ orinoco_change_mtu(struct net_device *de
 static void
 __orinoco_set_multicast_list(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err = 0;
 	int promisc, mc_count;
@@ -2554,7 +2554,7 @@ __orinoco_set_multicast_list(struct net_
 
 static int orinoco_ioctl_getiwrange(struct net_device *dev, struct iw_point *rrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int err = 0;
 	int mode;
 	struct iw_range range;
@@ -2699,7 +2699,7 @@ static int orinoco_ioctl_getiwrange(stru
 
 static int orinoco_ioctl_setiwencode(struct net_device *dev, struct iw_point *erq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int index = (erq->flags & IW_ENCODE_INDEX) - 1;
 	int setindex = priv->tx_key;
 	int enable = priv->wep_on;
@@ -2794,7 +2794,7 @@ static int orinoco_ioctl_setiwencode(str
 
 static int orinoco_ioctl_getiwencode(struct net_device *dev, struct iw_point *erq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int index = (erq->flags & IW_ENCODE_INDEX) - 1;
 	u16 xlen = 0;
 	char keybuf[ORINOCO_MAX_KEY_SIZE];
@@ -2841,7 +2841,7 @@ static int orinoco_ioctl_getiwencode(str
 
 static int orinoco_ioctl_setessid(struct net_device *dev, struct iw_point *erq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	char essidbuf[IW_ESSID_MAX_SIZE+1];
 	int err;
 	unsigned long flags;
@@ -2874,7 +2874,7 @@ static int orinoco_ioctl_setessid(struct
 
 static int orinoco_ioctl_getessid(struct net_device *dev, struct iw_point *erq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	char essidbuf[IW_ESSID_MAX_SIZE+1];
 	int active;
 	int err = 0;
@@ -2907,7 +2907,7 @@ static int orinoco_ioctl_getessid(struct
 
 static int orinoco_ioctl_setnick(struct net_device *dev, struct iw_point *nrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	char nickbuf[IW_ESSID_MAX_SIZE+1];
 	int err;
 	unsigned long flags;
@@ -2935,7 +2935,7 @@ static int orinoco_ioctl_setnick(struct 
 
 static int orinoco_ioctl_getnick(struct net_device *dev, struct iw_point *nrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	char nickbuf[IW_ESSID_MAX_SIZE+1];
 	int err;
 	unsigned long flags;
@@ -2957,7 +2957,7 @@ static int orinoco_ioctl_getnick(struct 
 
 static int orinoco_ioctl_setfreq(struct net_device *dev, struct iw_freq *frq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int chan = -1;
 	int err;
 	unsigned long flags;
@@ -2999,7 +2999,7 @@ static int orinoco_ioctl_setfreq(struct 
 
 static int orinoco_ioctl_getsens(struct net_device *dev, struct iw_param *srq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	u16 val;
 	int err;
@@ -3025,7 +3025,7 @@ static int orinoco_ioctl_getsens(struct 
 
 static int orinoco_ioctl_setsens(struct net_device *dev, struct iw_param *srq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int val = srq->value;
 	int err;
 	unsigned long flags;
@@ -3047,7 +3047,7 @@ static int orinoco_ioctl_setsens(struct 
 
 static int orinoco_ioctl_setrts(struct net_device *dev, struct iw_param *rrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int val = rrq->value;
 	int err;
 	unsigned long flags;
@@ -3070,7 +3070,7 @@ static int orinoco_ioctl_setrts(struct n
 
 static int orinoco_ioctl_setfrag(struct net_device *dev, struct iw_param *frq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int err = 0;
 	unsigned long flags;
 
@@ -3105,7 +3105,7 @@ supported on this firmware. Using MWO ro
 
 static int orinoco_ioctl_getfrag(struct net_device *dev, struct iw_param *frq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err = 0;
 	u16 val;
@@ -3143,7 +3143,7 @@ static int orinoco_ioctl_getfrag(struct 
 
 static int orinoco_ioctl_setrate(struct net_device *dev, struct iw_param *rrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int err = 0;
 	int ratemode = -1;
 	int bitrate; /* 100s of kilobits */
@@ -3186,7 +3186,7 @@ static int orinoco_ioctl_setrate(struct 
 
 static int orinoco_ioctl_getrate(struct net_device *dev, struct iw_param *rrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err = 0;
 	int ratemode;
@@ -3253,7 +3253,7 @@ static int orinoco_ioctl_getrate(struct 
 
 static int orinoco_ioctl_setpower(struct net_device *dev, struct iw_param *prq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int err = 0;
 	unsigned long flags;
 
@@ -3306,7 +3306,7 @@ static int orinoco_ioctl_setpower(struct
 
 static int orinoco_ioctl_getpower(struct net_device *dev, struct iw_param *prq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err = 0;
 	u16 enable, period, timeout, mcast;
@@ -3356,7 +3356,7 @@ static int orinoco_ioctl_getpower(struct
 #if WIRELESS_EXT > 10
 static int orinoco_ioctl_getretry(struct net_device *dev, struct iw_param *rrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err = 0;
 	u16 short_limit, long_limit, lifetime;
@@ -3409,7 +3409,7 @@ static int orinoco_ioctl_getretry(struct
 
 static int orinoco_ioctl_setibssport(struct net_device *dev, struct iwreq *wrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int val = *( (int *) wrq->u.name );
 	int err;
 	unsigned long flags;
@@ -3429,7 +3429,7 @@ static int orinoco_ioctl_setibssport(str
 
 static int orinoco_ioctl_getibssport(struct net_device *dev, struct iwreq *wrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int *val = (int *)wrq->u.name;
 	int err;
 	unsigned long flags;
@@ -3446,7 +3446,7 @@ static int orinoco_ioctl_getibssport(str
 
 static int orinoco_ioctl_setport3(struct net_device *dev, struct iwreq *wrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int val = *( (int *) wrq->u.name );
 	int err = 0;
 	unsigned long flags;
@@ -3488,7 +3488,7 @@ static int orinoco_ioctl_setport3(struct
 
 static int orinoco_ioctl_getport3(struct net_device *dev, struct iwreq *wrq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	int *val = (int *)wrq->u.name;
 	int err;
 	unsigned long flags;
@@ -3507,7 +3507,7 @@ static int orinoco_ioctl_getport3(struct
  * Jean II */
 static int orinoco_ioctl_setspy(struct net_device *dev, struct iw_point *srq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct sockaddr address[IW_MAX_SPY];
 	int number = srq->length;
 	int i;
@@ -3554,7 +3554,7 @@ static int orinoco_ioctl_setspy(struct n
 
 static int orinoco_ioctl_getspy(struct net_device *dev, struct iw_point *srq)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct sockaddr address[IW_MAX_SPY];
 	struct iw_quality spy_stat[IW_MAX_SPY];
 	int number;
@@ -3601,7 +3601,7 @@ static int orinoco_ioctl_getspy(struct n
 static int
 orinoco_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	struct iwreq *wrq = (struct iwreq *)rq;
 	int err = 0;
 	int tmp;
@@ -4057,7 +4057,7 @@ struct {
 
 static int orinoco_debug_dump_recs(struct net_device *dev)
 {
-	struct orinoco_private *priv = dev->priv;
+	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	u8 *val8;
 	u16 *val16;
@@ -4131,7 +4131,7 @@ struct net_device *alloc_orinocodev(int 
 	dev = alloc_etherdev(sizeof(struct orinoco_private) + sizeof_card);
 	if (!dev)
 		return NULL;
-	priv = (struct orinoco_private *)dev->priv;
+	priv = netdev_priv(dev);
 	priv->ndev = dev;
 	if (sizeof_card)
 		priv->card = (void *)((unsigned long)dev->priv + sizeof(struct orinoco_private));

_


--
~Randy
