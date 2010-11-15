From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/10] drivers/net/pcmcia: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:26 -0800
Message-ID: <b738d463c9bce47f059e19b8dde5970e53cbf3e4.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1379 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758494Ab0KOVMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 16:12:44 -0500
In-Reply-To: <cover.1289855436.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcmcia/axnet_cs.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index d2e166e..c65c9e1 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -865,7 +865,7 @@ static void do_set_multicast_list(struct net_device *dev);
 static int ax_open(struct net_device *dev)
 {
 	unsigned long flags;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	/*
 	 *	Grab the page lock so we own the register set, then call
@@ -916,7 +916,7 @@ static int ax_close(struct net_device *dev)
 static void axnet_tx_timeout(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int txsr, isr, tickssofar = jiffies - dev_trans_start(dev);
 	unsigned long flags;
 
@@ -963,7 +963,7 @@ static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int length, send_length, output_page;
 	unsigned long flags;
 	u8 packet[ETH_ZLEN];
@@ -1260,7 +1260,7 @@ static void ei_tx_err(struct net_device *dev)
 static void ei_tx_intr(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int status = inb(e8390_base + EN0_TSR);
     
 	/*
@@ -1344,7 +1344,7 @@ static void ei_tx_intr(struct net_device *dev)
 static void ei_receive(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned char rxing_page, this_frame, next_frame;
 	unsigned short current_offset;
 	int rx_pkt_count = 0;
@@ -1529,7 +1529,7 @@ static void ei_rx_overrun(struct net_device *dev)
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned long flags;
     
 	/* If the card is stopped, just return the present stats. */
@@ -1578,7 +1578,7 @@ static void do_set_multicast_list(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
 	int i;
-	struct ei_device *ei_local = (struct ei_device*)netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI))) {
 		memset(ei_local->mcfilter, 0, 8);
@@ -1636,7 +1636,7 @@ static void AX88190_init(struct net_device *dev, int startp)
 {
 	axnet_dev_t *info = PRIV(dev);
 	long e8390_base = dev->base_addr;
-	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
+	struct ei_device *ei_local = netdev_priv(dev);
 	int i;
 	int endcfg = ei_local->word16 ? (0x48 | ENDCFG_WTS) : 0x48;
     
@@ -1702,7 +1702,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page)
 {
 	long e8390_base = dev->base_addr;
- 	struct ei_device *ei_local __attribute((unused)) = (struct ei_device *) netdev_priv(dev);
+ 	struct ei_device *ei_local __attribute((unused)) = netdev_priv(dev);
     
 	if (inb_p(e8390_base) & E8390_TRANS) 
 	{
-- 
1.7.3.1.g432b3.dirty

