From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in 3c527
Date: Sun, 29 Feb 2004 15:01:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229150106.694b113b.rddunlap@osdl.org>
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



 drivers/net/3c527.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff -puN drivers/net/3c527.c~drivers_net_v2_casts drivers/net/3c527.c
--- linux-263-229/drivers/net/3c527.c~drivers_net_v2_casts	2004-02-29 14:04:11.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/3c527.c	2004-02-29 14:04:11.000000000 -0800
@@ -573,7 +573,7 @@ static inline void mc32_ready_poll(struc
 
 static int mc32_command_nowait(struct net_device *dev, u16 cmd, void *data, int len)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int ret = -1;
 
@@ -619,7 +619,7 @@ static int mc32_command_nowait(struct ne
   
 static int mc32_command(struct net_device *dev, u16 cmd, void *data, int len)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int ret = 0;
 	
@@ -671,7 +671,7 @@ static int mc32_command(struct net_devic
 
 static void mc32_start_transceiver(struct net_device *dev) {
 
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	/* Ignore RX overflow on device closure */ 
@@ -706,7 +706,7 @@ static void mc32_start_transceiver(struc
 
 static void mc32_halt_transceiver(struct net_device *dev) 
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	mc32_ready_poll(dev);	
@@ -743,7 +743,7 @@ static void mc32_halt_transceiver(struct
 	 
 static int mc32_load_rx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int i;
 	u16 rx_base;
 	volatile struct skb_header *p;
@@ -792,7 +792,7 @@ static int mc32_load_rx_ring(struct net_
 
 static void mc32_flush_rx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int i; 
 
 	for(i=0; i < RX_RING_LEN; i++) 
@@ -824,7 +824,7 @@ static void mc32_flush_rx_ring(struct ne
 
 static void mc32_load_tx_ring(struct net_device *dev)
 { 
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	volatile struct skb_header *p;
 	int i; 
 	u16 tx_base;
@@ -861,7 +861,7 @@ static void mc32_load_tx_ring(struct net
 
 static void mc32_flush_tx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int i;
 
 	for (i=0; i < TX_RING_LEN; i++)
@@ -899,7 +899,7 @@ static void mc32_flush_tx_ring(struct ne
 static int mc32_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	u8 one=1;
 	u8 regs;
 	u16 descnumbuffs[2] = {TX_RING_LEN, RX_RING_LEN};
@@ -1022,7 +1022,7 @@ static void mc32_timeout(struct net_devi
 
 static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	u32 head = atomic_read(&lp->tx_ring_head);
 	
 	volatile struct skb_header *p, *np;
@@ -1092,7 +1092,7 @@ static int mc32_send_packet(struct sk_bu
 
 static void mc32_update_stats(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	volatile struct mc32_stats *st = lp->stats; 
 
 	u32 rx_errors=0; 
@@ -1236,7 +1236,7 @@ static void mc32_rx_ring(struct net_devi
 
 static void mc32_tx_ring(struct net_device *dev) 
 {
-	struct mc32_local *lp=(struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	volatile struct skb_header *np;
 
 	/*
@@ -1333,7 +1333,7 @@ static irqreturn_t mc32_interrupt(int ir
 	}
  
 	ioaddr = dev->base_addr;
-	lp = (struct mc32_local *)dev->priv;
+	lp = dev->priv;
 
 	/* See whats cooking */
 
@@ -1450,7 +1450,7 @@ static irqreturn_t mc32_interrupt(int ir
 
 static int mc32_close(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	u8 regs;
@@ -1499,7 +1499,7 @@ static int mc32_close(struct net_device 
 
 static struct net_device_stats *mc32_get_stats(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	
 	mc32_update_stats(dev); 
 	return &lp->net_stats;
@@ -1531,7 +1531,7 @@ static struct net_device_stats *mc32_get
 
 static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = dev->priv;
 	u16 filt = (1<<2); /* Save Bad Packets, for stats purposes */ 
 
 	if (dev->flags&IFF_PROMISC)

_


--
~Randy
