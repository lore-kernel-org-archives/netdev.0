From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] s2io: Remove private boolean definitions
Date: Fri,  5 Jun 2009 11:07:59 +0200
Message-ID: <1244192879-17669-1-git-send-email-tklauser@distanz.ch>
Cc: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	anil.murthy@neterion.com, Tobias Klauser <tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:60592 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701AbZFEJPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 05:15:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the private definition of TRUE/FALSE and use the ones from
linux/stddef.h. Also remove the definition of BOOL which is not referenced
inside the driver anyway.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/s2io.c |   22 +++++++++++-----------
 drivers/net/s2io.h |    9 ---------
 2 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 1a4979f..f5dfae3 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1763,7 +1763,7 @@ static int init_nic(struct s2io_nic *nic)
 		 * by then we return error.
 		 */
 		time = 0;
-		while (TRUE) {
+		while (true) {
 			val64 = readq(&bar0->rti_command_mem);
 			if (!(val64 & RTI_CMD_MEM_STROBE_NEW_CMD))
 				break;
@@ -2136,7 +2136,7 @@ static int verify_pcc_quiescent(struct s2io_nic *sp, int flag)
 
 	herc = (sp->device_type == XFRAME_II_DEVICE);
 
-	if (flag == FALSE) {
+	if (flag == false) {
 		if ((!herc && (sp->pdev->revision >= 4)) || herc) {
 			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE))
 				ret = 1;
@@ -3586,7 +3586,7 @@ static void s2io_reset(struct s2io_nic * sp)
 		writeq(val64, &bar0->pcc_err_reg);
 	}
 
-	sp->device_enabled_once = FALSE;
+	sp->device_enabled_once = false;
 }
 
 /**
@@ -5572,10 +5572,10 @@ static void s2io_ethtool_getpause_data(struct net_device *dev,
 
 	val64 = readq(&bar0->rmac_pause_cfg);
 	if (val64 & RMAC_PAUSE_GEN_ENABLE)
-		ep->tx_pause = TRUE;
+		ep->tx_pause = true;
 	if (val64 & RMAC_PAUSE_RX_ENABLE)
-		ep->rx_pause = TRUE;
-	ep->autoneg = FALSE;
+		ep->rx_pause = true;
+	ep->autoneg = false;
 }
 
 /**
@@ -6806,7 +6806,7 @@ static void s2io_set_link(struct work_struct *work)
 					val64 |= ADAPTER_LED_ON;
 					writeq(val64, &bar0->adapter_control);
 				}
-				nic->device_enabled_once = TRUE;
+				nic->device_enabled_once = true;
 			} else {
 				DBG_PRINT(ERR_DBG, "%s: Error: ", dev->name);
 				DBG_PRINT(ERR_DBG, "device is not Quiescent\n");
@@ -7754,7 +7754,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	struct s2io_nic *sp;
 	struct net_device *dev;
 	int i, j, ret;
-	int dma_flag = FALSE;
+	int dma_flag = false;
 	u32 mac_up, mac_down;
 	u64 val64 = 0, tmp64 = 0;
 	struct XENA_dev_config __iomem *bar0 = NULL;
@@ -7777,7 +7777,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
-		dma_flag = TRUE;
+		dma_flag = true;
 		if (pci_set_consistent_dma_mask
 		    (pdev, DMA_BIT_MASK(64))) {
 			DBG_PRINT(ERR_DBG,
@@ -7818,7 +7818,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	sp->dev = dev;
 	sp->pdev = pdev;
 	sp->high_dma_flag = dma_flag;
-	sp->device_enabled_once = FALSE;
+	sp->device_enabled_once = false;
 	if (rx_ring_mode == 1)
 		sp->rxd_mode = RXD_MODE_1;
 	if (rx_ring_mode == 2)
@@ -7964,7 +7964,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-	if (sp->high_dma_flag == TRUE)
+	if (sp->high_dma_flag == true)
 		dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_TSO;
 	dev->features |= NETIF_F_TSO6;
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 55cb943..d5c5be6 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -18,15 +18,6 @@
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
 #define INV(d)  ((d&0xff)<<24) | (((d>>8)&0xff)<<16) | (((d>>16)&0xff)<<8)| ((d>>24)&0xff)
 
-#ifndef BOOL
-#define BOOL    int
-#endif
-
-#ifndef TRUE
-#define TRUE    1
-#define FALSE   0
-#endif
-
 #undef SUCCESS
 #define SUCCESS 0
 #define FAILURE -1
-- 
1.6.0.4

