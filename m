From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/8) arlan -- get rid of unnecessary casts.
Date: Thu, 25 Sep 2003 16:00:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925160026.28be8531.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of unneeded casts to cleanup readability.

diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:38:31 2003
+++ b/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:38:31 2003
@@ -143,7 +143,7 @@
 
 static inline int arlan_drop_tx(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	priv->stats.tx_errors++;
 	if (priv->Conf->tx_delay_ms)
@@ -167,10 +167,9 @@
 
 int arlan_command(struct net_device *dev, int command_p)
 {
-
-	volatile struct arlan_shmem *arlan = ((struct arlan_private *) dev->priv)->card;
-	struct arlan_conf_stru *conf = ((struct arlan_private *) dev->priv)->Conf;
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
+	volatile struct arlan_shmem *arlan = priv->card;
+	struct arlan_conf_stru *conf = priv->Conf;
 	int udelayed = 0;
 	int i = 0;
 	long long time_mks = arlan_time();
@@ -510,7 +509,7 @@
 
 static inline void arlan_command_process(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	int times = 0;
 	while (priv->waiting_command_mask && times < 8)
@@ -531,7 +530,7 @@
 
 static inline void arlan_retransmit_now(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 
 	ARLAN_DEBUG_ENTRY("arlan_retransmit_now");
@@ -570,7 +569,7 @@
 static void arlan_registration_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 
 	int lostTime = ((int) (jiffies - priv->registrationLastSeen)) * 1000 / HZ;
 	int bh_mark_needed = 0;
@@ -671,7 +670,8 @@
 
 static void arlan_print_registers(struct net_device *dev, int line)
 {
-	volatile struct arlan_shmem *arlan = ((struct arlan_private *) dev->priv)->card;
+	struct arlan_private *priv = dev->priv;
+	volatile struct arlan_shmem *arlan = priv->card;
 
 	u_char hostcpuLock, lancpuLock, controlRegister, cntrlRegImage,
 		txStatus, rxStatus, interruptInProgress, commandByte;
@@ -700,7 +700,7 @@
 {
 	int i;
 
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 	volatile struct arlan_shmem *arlan = priv->card;
 	struct arlan_conf_stru *conf = priv->Conf;
 
@@ -803,9 +803,9 @@
 
 static int arlan_hw_config(struct net_device *dev)
 {
-	volatile struct arlan_shmem *arlan = ((struct arlan_private *) dev->priv)->card;
-	struct arlan_conf_stru *conf = ((struct arlan_private *) dev->priv)->Conf;
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
+	volatile struct arlan_shmem *arlan = priv->card;
+	struct arlan_conf_stru *conf = priv->Conf;
 
 	ARLAN_DEBUG_ENTRY("arlan_hw_config");
 
@@ -886,8 +886,9 @@
 static int arlan_read_card_configuration(struct net_device *dev)
 {
 	u_char tlx415;
-	volatile struct arlan_shmem *arlan = ((struct arlan_private *) dev->priv)->card;
-	struct arlan_conf_stru *conf = ((struct arlan_private *) dev->priv)->Conf;
+	struct arlan_private *priv = dev->priv;
+	volatile struct arlan_shmem *arlan = priv->card;
+	struct arlan_conf_stru *conf = priv->Conf;
 
 	ARLAN_DEBUG_ENTRY("arlan_read_card_configuration");
 
@@ -1078,7 +1079,8 @@
 
 static int arlan_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct arlan_conf_stru *conf = ((struct arlan_private *) dev->priv)->Conf;
+	struct arlan_private *priv = dev->priv;
+	struct arlan_conf_stru *conf = priv->Conf;
 
 	ARLAN_DEBUG_ENTRY("arlan_change_mtu");
 	if (new_mtu > 2032)
@@ -1167,13 +1169,13 @@
 	dev->tx_timeout = arlan_tx_timeout;
 	dev->watchdog_timeo = 3*HZ;
 	
-	((struct arlan_private *) dev->priv)->irq_test_done = 0;
+	ap->irq_test_done = 0;
 	arlan_device[num] = dev;
-	((struct arlan_private *) arlan_device[num]->priv)->Conf = &(arlan_conf[num]);
+	ap->Conf = &arlan_conf[num];
 
-	((struct arlan_private *) dev->priv)->Conf->pre_Command_Wait = 40;
-	((struct arlan_private *) dev->priv)->Conf->rx_tweak1 = 30;
-	((struct arlan_private *) dev->priv)->Conf->rx_tweak2 = 0;
+	ap->Conf->pre_Command_Wait = 40;
+	ap->Conf->rx_tweak1 = 30;
+	ap->Conf->rx_tweak2 = 0;
 
 	ARLAN_DEBUG_EXIT("arlan_allocate_device");
 	return (int) dev;
@@ -1217,7 +1219,7 @@
 
 static int arlan_open(struct net_device *dev)
 {
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 	volatile struct arlan_shmem *arlan = priv->card;
 	int ret = 0;
 
@@ -1228,7 +1230,7 @@
 	if (ret != 0)
 		return ret;
 
-	arlan = ((struct arlan_private *) dev->priv)->card;
+	arlan = priv->card;
 	ret = request_irq(dev->irq, &arlan_interrupt, 0, dev->name, dev);
 	if (ret)
 	{
@@ -1289,7 +1291,7 @@
 
 static int arlan_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 	short length;
 	unsigned char *buf;
 
@@ -1326,7 +1328,7 @@
 
 static inline int DoNotReTransmitCrap(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	if (TXLAST(dev).length < priv->Conf->ReTransmitPacketMaxSize)
 		return 1;
@@ -1336,7 +1338,7 @@
 
 static inline int DoNotWaitReTransmitCrap(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	if (TXLAST(dev).length < priv->Conf->waitReTransmitPacketMaxSize)
 		return 1;
@@ -1345,7 +1347,7 @@
 
 static inline void arlan_queue_retransmit(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	ARLAN_DEBUG_ENTRY("arlan_queue_retransmit");
 
@@ -1360,7 +1362,7 @@
 
 static inline void RetryOrFail(struct net_device *dev)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	ARLAN_DEBUG_ENTRY("RetryOrFail");
 
@@ -1381,7 +1383,7 @@
 
 static void arlan_tx_done_interrupt(struct net_device *dev, int status)
 {
-	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
+	struct arlan_private *priv = dev->priv;
 
 	ARLAN_DEBUG_ENTRY("arlan_tx_done_interrupt");
 
@@ -1524,7 +1526,7 @@
 	char *skbtmp;
 	int i = 0;
 
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 	volatile struct arlan_shmem *arlan = priv->card;
 	struct arlan_conf_stru *conf = priv->Conf;
 
@@ -1676,7 +1678,7 @@
 
 static void arlan_process_interrupt(struct net_device *dev)
 {
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 	volatile struct arlan_shmem *arlan = priv->card;
 	u_char rxStatus = READSHMB(arlan->rxStatus);
 	u_char txStatus = READSHMB(arlan->txStatus);
@@ -1782,7 +1784,7 @@
 static irqreturn_t arlan_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = dev_id;
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 	volatile struct arlan_shmem *arlan = priv->card;
 	u_char rxStatus = READSHMB(arlan->rxStatus);
 	u_char txStatus = READSHMB(arlan->txStatus);
@@ -1805,14 +1807,8 @@
 
 static int arlan_close(struct net_device *dev)
 {
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
+	struct arlan_private *priv = dev->priv;
 
-	if (!dev)
-	{
-		printk(KERN_CRIT "arlan: No Device\n");
-		return 0;
-	}
-	priv = (struct arlan_private *) dev->priv;
 	if (!priv)
 	{
 		printk(KERN_CRIT "arlan: No Device priv \n");
@@ -1850,8 +1846,8 @@
 
 static struct net_device_stats *arlan_statistics(struct net_device *dev)
 {
-	struct arlan_private *priv = (struct arlan_private *) dev->priv;
-	volatile struct arlan_shmem *arlan = ((struct arlan_private *) dev->priv)->card;
+	struct arlan_private *priv = dev->priv;
+	volatile struct arlan_shmem *arlan = priv->card;
 
 
 	ARLAN_DEBUG_ENTRY("arlan_statistics");
@@ -1880,8 +1876,9 @@
 
 static void arlan_set_multicast(struct net_device *dev)
 {
-	volatile struct arlan_shmem *arlan = ((struct arlan_private *) dev->priv)->card;
-	struct arlan_conf_stru *conf = ((struct arlan_private *) dev->priv)->Conf;
+	struct arlan_private *priv = dev->priv;
+	volatile struct arlan_shmem *arlan = priv->card;
+	struct arlan_conf_stru *conf = priv->Conf;
 	int board_conf_needed = 0;
 
 
