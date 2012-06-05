From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH v3 net-next 4/5] gianfar: Remove superfluous initialisations
Date: Tue,  5 Jun 2012 15:42:14 +0200
Message-ID: <1338903735-24527-5-git-send-email-jan.ceuleers@computer.org>
References: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:49477 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757210Ab2FENpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:45:05 -0400
In-Reply-To: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 drivers/net/ethernet/freescale/gianfar.c |   30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index ed0b136..f00a095 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -428,7 +428,7 @@ static struct net_device_stats *gfar_get_stats(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	unsigned long rx_packets = 0, rx_bytes = 0, rx_dropped = 0;
 	unsigned long tx_packets = 0, tx_bytes = 0;
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_packets += priv->rx_queue[i]->stats.rx_packets;
@@ -470,7 +470,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 
 void lock_rx_qs(struct gfar_private *priv)
 {
-	int i = 0x0;
+	int i;
 
 	for (i = 0; i < priv->num_rx_queues; i++)
 		spin_lock(&priv->rx_queue[i]->rxlock);
@@ -478,7 +478,7 @@ void lock_rx_qs(struct gfar_private *priv)
 
 void lock_tx_qs(struct gfar_private *priv)
 {
-	int i = 0x0;
+	int i;
 
 	for (i = 0; i < priv->num_tx_queues; i++)
 		spin_lock(&priv->tx_queue[i]->txlock);
@@ -486,7 +486,7 @@ void lock_tx_qs(struct gfar_private *priv)
 
 void unlock_rx_qs(struct gfar_private *priv)
 {
-	int i = 0x0;
+	int i;
 
 	for (i = 0; i < priv->num_rx_queues; i++)
 		spin_unlock(&priv->rx_queue[i]->rxlock);
@@ -494,7 +494,7 @@ void unlock_rx_qs(struct gfar_private *priv)
 
 void unlock_tx_qs(struct gfar_private *priv)
 {
-	int i = 0x0;
+	int i;
 
 	for (i = 0; i < priv->num_tx_queues; i++)
 		spin_unlock(&priv->tx_queue[i]->txlock);
@@ -516,7 +516,7 @@ static inline int gfar_uses_fcb(struct gfar_private *priv)
 
 static void free_tx_pointers(struct gfar_private *priv)
 {
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_tx_queues; i++)
 		kfree(priv->tx_queue[i]);
@@ -524,7 +524,7 @@ static void free_tx_pointers(struct gfar_private *priv)
 
 static void free_rx_pointers(struct gfar_private *priv)
 {
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_rx_queues; i++)
 		kfree(priv->rx_queue[i]);
@@ -532,7 +532,7 @@ static void free_rx_pointers(struct gfar_private *priv)
 
 static void unmap_group_regs(struct gfar_private *priv)
 {
-	int i = 0;
+	int i;
 
 	for (i = 0; i < MAXGROUPS; i++)
 		if (priv->gfargrp[i].regs)
@@ -541,7 +541,7 @@ static void unmap_group_regs(struct gfar_private *priv)
 
 static void disable_napi(struct gfar_private *priv)
 {
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_grps; i++)
 		napi_disable(&priv->gfargrp[i].napi);
@@ -549,7 +549,7 @@ static void disable_napi(struct gfar_private *priv)
 
 static void enable_napi(struct gfar_private *priv)
 {
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_grps; i++)
 		napi_enable(&priv->gfargrp[i].napi);
@@ -1514,7 +1514,7 @@ static void init_registers(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = NULL;
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_grps; i++) {
 		regs = priv->gfargrp[i].regs;
@@ -1589,7 +1589,7 @@ static void gfar_halt_nodisable(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = NULL;
 	u32 tempval;
-	int i = 0;
+	int i;
 
 	for (i = 0; i < priv->num_grps; i++) {
 		regs = priv->gfargrp[i].regs;
@@ -1976,13 +1976,11 @@ static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 				    int fcb_length)
 {
-	u8 flags = 0;
-
 	/* If we're here, it's a IP packet with a TCP or UDP
 	 * payload.  We set it to checksum, using a pseudo-header
 	 * we provide
 	 */
-	flags = TXFCB_DEFAULT;
+	u8 flags = TXFCB_DEFAULT;
 
 	/* Tell the controller what the protocol is
 	 * And provide the already calculated phcs
@@ -2900,7 +2898,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 static void gfar_netpoll(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	int i = 0;
+	int i;
 
 	/* If the device has multiple interrupts, run tx/rx */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-- 
1.7.9.5
