From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: variables reach -1, but 0 tested
Date: Sat, 31 Jan 2009 11:36:30 +0100
Message-ID: <498429AE.1080404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:36503 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbZAaKgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 05:36:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a postfix decrement these reach -1 rather than 0,
but after the loop it is tested whether they have become 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/ibm_newemac/phy.c |    4 ++--
 drivers/net/smc911x.c         |    2 +-
 drivers/net/smsc9420.c        |   12 ++++++------
 drivers/net/sungem.c          |    2 +-
 drivers/net/sunqe.c           |    2 +-
 drivers/net/tsi108_eth.c      |    2 +-
 drivers/net/tulip/de2104x.c   |    2 +-
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index c40cd8d..ac9d964 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -60,7 +60,7 @@ int emac_mii_reset_phy(struct mii_phy *phy)
 
 	udelay(300);
 
-	while (limit--) {
+	while (--limit) {
 		val = phy_read(phy, MII_BMCR);
 		if (val >= 0 && (val & BMCR_RESET) == 0)
 			break;
@@ -84,7 +84,7 @@ int emac_mii_reset_gpcs(struct mii_phy *phy)
 
 	udelay(300);
 
-	while (limit--) {
+	while (--limit) {
 		val = gpcs_phy_read(phy, MII_BMCR);
 		if (val >= 0 && (val & BMCR_RESET) == 0)
 			break;
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index bf3aa2a..527c336 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -220,7 +220,7 @@ static void smc911x_reset(struct net_device *dev)
 
 	/* make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout=1000;
-	while ( timeout-- && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
+	while ( --timeout && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
 		udelay(10);
 	}
 	if (timeout == 0){
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index c14a4c6..41f5303 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -498,7 +498,7 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 static void smsc9420_stop_tx(struct smsc9420_pdata *pd)
 {
 	u32 dmac_control, mac_cr, dma_intr_ena;
-	int timeOut = 1000;
+	int timeout = 1000;
 
 	/* disable TX DMAC */
 	dmac_control = smsc9420_reg_read(pd, DMAC_CONTROL);
@@ -506,13 +506,13 @@ static void smsc9420_stop_tx(struct smsc9420_pdata *pd)
 	smsc9420_reg_write(pd, DMAC_CONTROL, dmac_control);
 
 	/* Wait max 10ms for transmit process to stop */
-	while (timeOut--) {
+	while (--timeout) {
 		if (smsc9420_reg_read(pd, DMAC_STATUS) & DMAC_STS_TS_)
 			break;
 		udelay(10);
 	}
 
-	if (!timeOut)
+	if (!timeout)
 		smsc_warn(IFDOWN, "TX DMAC failed to stop");
 
 	/* ACK Tx DMAC stop bit */
@@ -596,7 +596,7 @@ static void smsc9420_free_rx_ring(struct smsc9420_pdata *pd)
 
 static void smsc9420_stop_rx(struct smsc9420_pdata *pd)
 {
-	int timeOut = 1000;
+	int timeout = 1000;
 	u32 mac_cr, dmac_control, dma_intr_ena;
 
 	/* mask RX DMAC interrupts */
@@ -617,13 +617,13 @@ static void smsc9420_stop_rx(struct smsc9420_pdata *pd)
 	smsc9420_pci_flush_write(pd);
 
 	/* wait up to 10ms for receive to stop */
-	while (timeOut--) {
+	while (--timeout) {
 		if (smsc9420_reg_read(pd, DMAC_STATUS) & DMAC_STS_RS_)
 			break;
 		udelay(10);
 	}
 
-	if (!timeOut)
+	if (!timeout)
 		smsc_warn(IFDOWN, "RX DMAC did not stop! timeout.");
 
 	/* ACK the Rx DMAC stop bit */
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 86c765d..b17efa9 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -148,7 +148,7 @@ static u16 __phy_read(struct gem *gp, int phy_addr, int reg)
 	cmd |= (MIF_FRAME_TAMSB);
 	writel(cmd, gp->regs + MIF_FRAME);
 
-	while (limit--) {
+	while (--limit) {
 		cmd = readl(gp->regs + MIF_FRAME);
 		if (cmd & MIF_FRAME_TALSB)
 			break;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 6e8f377..fe0c3f2 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -227,7 +227,7 @@ static int qe_init(struct sunqe *qep, int from_irq)
 	if (!(sbus_readb(mregs + MREGS_PHYCONFIG) & MREGS_PHYCONFIG_LTESTDIS)) {
 		int tries = 50;
 
-		while (tries--) {
+		while (--tries) {
 			u8 tmp;
 
 			mdelay(5);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 75461db..a9fd2b2 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1237,7 +1237,7 @@ static void tsi108_init_phy(struct net_device *dev)
 	spin_lock_irqsave(&phy_lock, flags);
 
 	tsi108_write_mii(data, MII_BMCR, BMCR_RESET);
-	while (i--){
+	while (--i) {
 		if(!(tsi108_read_mii(data, MII_BMCR) & BMCR_RESET))
 			break;
 		udelay(10);
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d5d53b6..0bf2114 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -392,7 +392,7 @@ static void de_rx (struct de_private *de)
 	unsigned drop = 0;
 	int rc;
 
-	while (rx_work--) {
+	while (--rx_work) {
 		u32 status, len;
 		dma_addr_t mapping;
 		struct sk_buff *skb, *copy_skb;
