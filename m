From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in net/pcmcia/
Date: Sun, 29 Feb 2004 14:38:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229143837.50d9fa1d.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/pcmcia/3c574_cs.c    |   18 +++++++++---------
 drivers/net/pcmcia/3c589_cs.c    |   14 +++++++-------
 drivers/net/pcmcia/com20020_cs.c |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c  |   14 +++++++-------
 drivers/net/pcmcia/ibmtr_cs.c    |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c |    8 ++++----
 6 files changed, 29 insertions(+), 29 deletions(-)

diff -puN drivers/net/pcmcia/3c574_cs.c~net_pcmcia_casts drivers/net/pcmcia/3c574_cs.c
--- linux-263-229/drivers/net/pcmcia/3c574_cs.c~net_pcmcia_casts	2004-02-29 13:55:31.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/pcmcia/3c574_cs.c	2004-02-29 13:55:31.000000000 -0800
@@ -733,7 +733,7 @@ static void mdio_write(ioaddr_t ioaddr, 
 /* Reset and restore all of the 3c574 registers. */
 static void tc574_reset(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	int i, ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -814,7 +814,7 @@ static void tc574_reset(struct net_devic
 
 static int el3_open(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	dev_link_t *link = &lp->link;
 
 	if (!DEV_OK(link))
@@ -837,7 +837,7 @@ static int el3_open(struct net_device *d
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	ioaddr_t ioaddr = dev->base_addr;
 	
 	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
@@ -852,7 +852,7 @@ static void el3_tx_timeout(struct net_de
 
 static void pop_tx_status(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	ioaddr_t ioaddr = dev->base_addr;
 	int i;
     
@@ -877,7 +877,7 @@ static void pop_tx_status(struct net_dev
 static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	ioaddr_t ioaddr = dev->base_addr;
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	unsigned long flags;
 
 	DEBUG(3, "%s: el3_start_xmit(length = %ld) called, "
@@ -1074,7 +1074,7 @@ reschedule:
 
 static struct net_device_stats *el3_get_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 
 	if (netif_device_present(dev)) {
 		unsigned long flags;
@@ -1091,7 +1091,7 @@ static struct net_device_stats *el3_get_
  */
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	ioaddr_t ioaddr = dev->base_addr;
 	u8 rx, tx, up;
 
@@ -1128,7 +1128,7 @@ static void update_stats(struct net_devi
 
 static int el3_rx(struct net_device *dev, int worklimit)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	ioaddr_t ioaddr = dev->base_addr;
 	short rx_status;
 	
@@ -1190,7 +1190,7 @@ static struct ethtool_ops netdev_ethtool
 /* Provide ioctl() calls to examine the MII xcvr state. */
 static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	ioaddr_t ioaddr = dev->base_addr;
 	u16 *data = (u16 *)&rq->ifr_data;
 	int phy = lp->phys & 0x1f;
diff -puN drivers/net/pcmcia/3c589_cs.c~net_pcmcia_casts drivers/net/pcmcia/3c589_cs.c
--- linux-263-229/drivers/net/pcmcia/3c589_cs.c~net_pcmcia_casts	2004-02-29 13:55:31.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/pcmcia/3c589_cs.c	2004-02-29 13:55:31.000000000 -0800
@@ -526,7 +526,7 @@ static u16 read_eeprom(ioaddr_t ioaddr, 
 */
 static void tc589_set_xcvr(struct net_device *dev, int if_port)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     
     EL3WINDOW(0);
@@ -648,7 +648,7 @@ static int el3_config(struct net_device 
 
 static int el3_open(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     dev_link_t *link = &lp->link;
     
     if (!DEV_OK(link))
@@ -672,7 +672,7 @@ static int el3_open(struct net_device *d
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     
     printk(KERN_WARNING "%s: Transmit timed out!\n", dev->name);
@@ -687,7 +687,7 @@ static void el3_tx_timeout(struct net_de
 
 static void pop_tx_status(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     int i;
     
@@ -906,7 +906,7 @@ reschedule:
 
 static struct net_device_stats *el3_get_stats(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     unsigned long flags;
     dev_link_t *link = &lp->link;
 
@@ -928,7 +928,7 @@ static struct net_device_stats *el3_get_
 */
 static void update_stats(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
 
     DEBUG(2, "%s: updating the statistics.\n", dev->name);
@@ -955,7 +955,7 @@ static void update_stats(struct net_devi
 
 static int el3_rx(struct net_device *dev)
 {
-    struct el3_private *lp = (struct el3_private *)dev->priv;
+    struct el3_private *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     int worklimit = 32;
     short rx_status;
diff -puN drivers/net/pcmcia/com20020_cs.c~net_pcmcia_casts drivers/net/pcmcia/com20020_cs.c
--- linux-263-229/drivers/net/pcmcia/com20020_cs.c~net_pcmcia_casts	2004-02-29 13:55:31.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/pcmcia/com20020_cs.c	2004-02-29 13:55:31.000000000 -0800
@@ -492,7 +492,7 @@ static int com20020_event(event_t event,
             pcmcia_request_configuration(link->handle, &link->conf);
             if (link->open) {
 		int ioaddr = dev->base_addr;
-		struct arcnet_local *lp = (struct arcnet_local *)dev->priv;
+		struct arcnet_local *lp = dev->priv;
 		ARCRESET;
             }
         }
diff -puN drivers/net/pcmcia/fmvj18x_cs.c~net_pcmcia_casts drivers/net/pcmcia/fmvj18x_cs.c
--- linux-263-229/drivers/net/pcmcia/fmvj18x_cs.c~net_pcmcia_casts	2004-02-29 13:55:31.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/pcmcia/fmvj18x_cs.c	2004-02-29 13:55:31.000000000 -0800
@@ -862,7 +862,7 @@ static irqreturn_t fjn_interrupt(int irq
 
 static void fjn_tx_timeout(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
 
     printk(KERN_NOTICE "%s: transmit timed out with status %04x, %s?\n",
@@ -892,7 +892,7 @@ static void fjn_tx_timeout(struct net_de
 
 static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     short length = skb->len;
     
@@ -966,7 +966,7 @@ static int fjn_start_xmit(struct sk_buff
 
 static void fjn_reset(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     int i;
 
@@ -1052,7 +1052,7 @@ static void fjn_reset(struct net_device 
 
 static void fjn_rx(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     int boguscount = 10;	/* 5 -> 10: by agy 19940922 */
 
@@ -1181,7 +1181,7 @@ static int fjn_config(struct net_device 
 
 static int fjn_open(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     dev_link_t *link = &lp->link;
 
     DEBUG(4, "fjn_open('%s').\n", dev->name);
@@ -1206,7 +1206,7 @@ static int fjn_open(struct net_device *d
 
 static int fjn_close(struct net_device *dev)
 {
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     dev_link_t *link = &lp->link;
     ioaddr_t ioaddr = dev->base_addr;
 
@@ -1252,7 +1252,7 @@ static struct net_device_stats *fjn_get_
 static void set_rx_mode(struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
-    struct local_info_t *lp = (struct local_info_t *)dev->priv;
+    struct local_info_t *lp = dev->priv;
     u_char mc_filter[8];		 /* Multicast hash filter */
     u_long flags;
     int i;
diff -puN drivers/net/pcmcia/ibmtr_cs.c~net_pcmcia_casts drivers/net/pcmcia/ibmtr_cs.c
--- linux-263-229/drivers/net/pcmcia/ibmtr_cs.c~net_pcmcia_casts	2004-02-29 13:55:31.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/pcmcia/ibmtr_cs.c	2004-02-29 13:55:31.000000000 -0800
@@ -256,7 +256,7 @@ static void ibmtr_detach(dev_link_t *lin
 	unregister_netdev(dev);
 
     {
-	struct tok_info *ti = (struct tok_info *)dev->priv;
+	struct tok_info *ti = dev->priv;
 	del_timer_sync(&(ti->tr_timer));
     }
     if (link->state & DEV_CONFIG)
diff -puN drivers/net/pcmcia/smc91c92_cs.c~net_pcmcia_casts drivers/net/pcmcia/smc91c92_cs.c
--- linux-263-229/drivers/net/pcmcia/smc91c92_cs.c~net_pcmcia_casts	2004-02-29 13:55:31.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/pcmcia/smc91c92_cs.c	2004-02-29 13:55:31.000000000 -0800
@@ -1460,7 +1460,7 @@ static int smc_start_xmit(struct sk_buff
 
 static void smc_tx_err(struct net_device * dev)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     int saved_packet = inw(ioaddr + PNR_ARR) & 0xff;
     int packet_no = inw(ioaddr + FIFO_PORTS) & 0x7f;
@@ -1657,7 +1657,7 @@ irq_done:
 
 static void smc_rx(struct net_device *dev)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     int rx_status;
     int packet_length;	/* Caution: not frame length, rather words
@@ -1725,7 +1725,7 @@ static void smc_rx(struct net_device *de
 
 static struct net_device_stats *smc_get_stats(struct net_device *dev)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = dev->priv;
     /* Nothing to update - the 91c92 is a pretty primative chip. */
     return &smc->stats;
 }
@@ -1830,7 +1830,7 @@ static int s9k_config(struct net_device 
 */
 static void smc_set_xcvr(struct net_device *dev, int if_port)
 {
-    struct smc_private *smc = (struct smc_private *)dev->priv;
+    struct smc_private *smc = dev->priv;
     ioaddr_t ioaddr = dev->base_addr;
     u_short saved_bank;
 

_

--
~Randy
