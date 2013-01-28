From: Barry Grussling <barry@grussling.com>
Subject: [PATCH net-next] ethoc: Cleanup driver format
Date: Sun, 27 Jan 2013 20:44:36 -0800
Message-ID: <1359348276-15230-1-git-send-email-barry@grussling.com>
Cc: Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:52740 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab3A1Eou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 23:44:50 -0500
Received: by mail-pb0-f45.google.com with SMTP id rq13so1229978pbb.32
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 20:44:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>

Cleanup the format of ethoc.c to meet network driver style as
per checkpatch.pl.

Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/ethernet/ethoc.c |   34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8db1c06..8504d2c 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -206,7 +206,7 @@ struct ethoc {
 	unsigned int num_rx;
 	unsigned int cur_rx;
 
-	void** vma;
+	void **vma;
 
 	struct net_device *netdev;
 	struct napi_struct napi;
@@ -292,7 +292,7 @@ static int ethoc_init_ring(struct ethoc *dev, unsigned long mem_start)
 {
 	struct ethoc_bd bd;
 	int i;
-	void* vma;
+	void *vma;
 
 	dev->cur_tx = 0;
 	dev->dty_tx = 0;
@@ -447,8 +447,8 @@ static int ethoc_rx(struct net_device *dev, int limit)
 				netif_receive_skb(skb);
 			} else {
 				if (net_ratelimit())
-					dev_warn(&dev->dev, "low on memory - "
-							"packet dropped\n");
+					dev_warn(&dev->dev,
+					    "low on memory - packet dropped\n");
 
 				dev->stats.rx_dropped++;
 				break;
@@ -555,9 +555,8 @@ static irqreturn_t ethoc_interrupt(int irq, void *dev_id)
 	pending = ethoc_read(priv, INT_SOURCE);
 	pending &= mask;
 
-	if (unlikely(pending == 0)) {
+	if (unlikely(pending == 0))
 		return IRQ_NONE;
-	}
 
 	ethoc_ack_irq(priv, pending);
 
@@ -620,7 +619,7 @@ static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 	ethoc_write(priv, MIIADDRESS, MIIADDRESS_ADDR(phy, reg));
 	ethoc_write(priv, MIICOMMAND, MIICOMMAND_READ);
 
-	for (i=0; i < 5; i++) {
+	for (i = 0; i < 5; i++) {
 		u32 status = ethoc_read(priv, MIISTATUS);
 		if (!(status & MIISTATUS_BUSY)) {
 			u32 data = ethoc_read(priv, MIIRX_DATA);
@@ -628,7 +627,7 @@ static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 			ethoc_write(priv, MIICOMMAND, 0);
 			return data;
 		}
-		usleep_range(100,200);
+		usleep_range(100, 200);
 	}
 
 	return -EBUSY;
@@ -643,14 +642,14 @@ static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	ethoc_write(priv, MIITX_DATA, val);
 	ethoc_write(priv, MIICOMMAND, MIICOMMAND_WRITE);
 
-	for (i=0; i < 5; i++) {
+	for (i = 0; i < 5; i++) {
 		u32 stat = ethoc_read(priv, MIISTATUS);
 		if (!(stat & MIISTATUS_BUSY)) {
 			/* reset MII command register */
 			ethoc_write(priv, MIICOMMAND, 0);
 			return 0;
 		}
-		usleep_range(100,200);
+		usleep_range(100, 200);
 	}
 
 	return -EBUSY;
@@ -671,11 +670,10 @@ static int ethoc_mdio_probe(struct net_device *dev)
 	struct phy_device *phy;
 	int err;
 
-	if (priv->phy_id != -1) {
+	if (priv->phy_id != -1)
 		phy = priv->mdio->phy_map[priv->phy_id];
-	} else {
+	else
 		phy = phy_find_first(priv->mdio);
-	}
 
 	if (!phy) {
 		dev_err(&dev->dev, "no PHY found\n");
@@ -1022,7 +1020,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	dev_dbg(&pdev->dev, "ethoc: num_tx: %d num_rx: %d\n",
 		priv->num_tx, priv->num_rx);
 
-	priv->vma = devm_kzalloc(&pdev->dev, num_bd*sizeof(void*), GFP_KERNEL);
+	priv->vma = devm_kzalloc(&pdev->dev, num_bd*sizeof(void *), GFP_KERNEL);
 	if (!priv->vma) {
 		ret = -ENOMEM;
 		goto error;
@@ -1038,7 +1036,7 @@ static int ethoc_probe(struct platform_device *pdev)
 
 #ifdef CONFIG_OF
 		{
-		const uint8_t* mac;
+		const uint8_t *mac;
 
 		mac = of_get_property(pdev->dev.of_node,
 				      "local-mac-address",
@@ -1050,12 +1048,14 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	/* Check that the given MAC address is valid. If it isn't, read the
-	 * current MAC from the controller. */
+	 * current MAC from the controller.
+	 */
 	if (!is_valid_ether_addr(netdev->dev_addr))
 		ethoc_get_mac_address(netdev, netdev->dev_addr);
 
 	/* Check the MAC again for validity, if it still isn't choose and
-	 * program a random one. */
+	 * program a random one.
+	 */
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		eth_random_addr(netdev->dev_addr);
 		random_mac = true;
-- 
1.7.9.5
