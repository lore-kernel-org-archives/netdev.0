From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 1/3] hp100: use netdev_priv (rev 2)
Date: Tue, 19 Oct 2004 14:16:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019141622.3d5a7c14@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a revised version of the hp100 patch sequence.
First one just does netdev_priv.
Worked with Jean to get these patches tested.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	2004-10-18 15:51:14 -07:00
+++ b/drivers/net/hp100.c	2004-10-18 15:51:14 -07:00
@@ -280,8 +280,8 @@
  * address - Jean II */
 static inline dma_addr_t virt_to_whatever(struct net_device *dev, u32 * ptr)
 {
-	return ((u_long) ptr) +
-		((struct hp100_private *) (dev->priv))->whatever_offset;
+	struct hp100_private *lp = netdev_priv(dev);
+	return ((u_long) ptr) + lp->whatever_offset;
 }
 
 /* TODO: This function should not really be needed in a good design... */
@@ -631,7 +631,7 @@
 	}
 
 	/* Initialise the "private" data structure for this card. */
-	lp = (struct hp100_private *) dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock_init(&lp->lock);
 	strlcpy(lp->id, eid, HP100_SIG_LEN);
@@ -781,7 +781,7 @@
 static void hp100_hwinit(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4202, TRACE);
@@ -875,7 +875,7 @@
 static void hp100_mmuinit(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	int i;
 
 #ifdef HP100_DEBUG_B
@@ -1053,7 +1053,7 @@
 
 static int hp100_open(struct net_device *dev)
 {
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 #ifdef HP100_DEBUG_B
 	int ioaddr = dev->base_addr;
 #endif
@@ -1093,7 +1093,7 @@
 static int hp100_close(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4205, TRACE);
@@ -1126,7 +1126,7 @@
  */
 static void hp100_init_pdls(struct net_device *dev)
 {
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	hp100_ring_t *ringptr;
 	u_int *pageptr;		/* Warning : increment by 4 - Jean II */
 	int i;
@@ -1310,7 +1310,7 @@
 {
 	int ioaddr = dev->base_addr;
 
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	hp100_ring_t *ringptr;
 
 #ifdef HP100_DEBUG_B
@@ -1351,7 +1351,7 @@
 static void hp100_BM_shutdown(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	unsigned long time;
 
 #ifdef HP100_DEBUG_B
@@ -1432,7 +1432,7 @@
 
 static int hp100_check_lan(struct net_device *dev)
 {
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 	if (lp->lan_type < 0) {	/* no LAN type detected yet? */
 		hp100_stop_interface(dev);
@@ -1458,7 +1458,7 @@
 	unsigned long flags;
 	int i, ok_flag;
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	hp100_ring_t *ringptr;
 
 #ifdef HP100_DEBUG_B
@@ -1576,7 +1576,7 @@
  */
 static void hp100_clean_txring(struct net_device *dev)
 {
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int donecount;
 
@@ -1615,7 +1615,7 @@
 	int i, ok_flag;
 	int ioaddr = dev->base_addr;
 	u_short val;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4212, TRACE);
@@ -1755,7 +1755,7 @@
 {
 	int packets, pkt_len;
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	u_int header;
 	struct sk_buff *skb;
 
@@ -1864,7 +1864,7 @@
 static void hp100_rx_bm(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	hp100_ring_t *ptr;
 	u_int header;
 	int pkt_len;
@@ -1973,7 +1973,7 @@
 {
 	unsigned long flags;
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4215, TRACE);
@@ -1991,7 +1991,7 @@
 {
 	int ioaddr = dev->base_addr;
 	u_short val;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4216, TRACE);
@@ -2017,7 +2017,7 @@
 #ifdef HP100_DEBUG_B
 	int ioaddr = dev->base_addr;
 #endif
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	int ioaddr = dev->base_addr;
@@ -2061,7 +2061,7 @@
 {
 	unsigned long flags;
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4218, TRACE);
@@ -2191,7 +2191,7 @@
 static irqreturn_t hp100_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 	int ioaddr;
 	u_int val;
@@ -2322,7 +2322,7 @@
 {
 	unsigned long flags;
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4220, TRACE);
@@ -2381,7 +2381,7 @@
 
 static void hp100_stop_interface(struct net_device *dev)
 {
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	u_int val;
 
@@ -2442,7 +2442,7 @@
 {
 	int ioaddr = dev->base_addr;
 	u_short val_VG, val_10;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4223, TRACE);
@@ -2488,7 +2488,7 @@
 
 static int hp100_down_vg_link(struct net_device *dev)
 {
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long time;
 	long savelan, newlan;
@@ -2604,7 +2604,7 @@
 static int hp100_login_to_vg_hub(struct net_device *dev, u_short force_relogin)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 	u_short val = 0;
 	unsigned long time;
 	int startst;
@@ -2775,7 +2775,7 @@
 static void hp100_cascade_reset(struct net_device *dev, u_short enable)
 {
 	int ioaddr = dev->base_addr;
-	struct hp100_private *lp = (struct hp100_private *) dev->priv;
+	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4226, TRACE);
@@ -2836,7 +2836,7 @@
 
 static void cleanup_dev(struct net_device *d)
 {
-	struct hp100_private *p = (struct hp100_private *) d->priv;
+	struct hp100_private *p = netdev_priv(d);
 
 	unregister_netdev(d);
 	release_region(d->base_addr, HP100_REGION_SIZE);
