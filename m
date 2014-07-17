From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 10/14] be2net: use "if (!foo)" test style
Date: Thu, 17 Jul 2014 16:20:28 +0530
Message-ID: <1405594232-30818-11-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22736 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756803AbaGQKsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:39 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Replace "if (foo == NULL)" statements with "if (!foo)" to be consistent
across the driver.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1abca8b..b354b28 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2034,7 +2034,7 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 	 */
 	for (;;) {
 		rxcp = be_rx_compl_get(rxo);
-		if (rxcp == NULL) {
+		if (!rxcp) {
 			if (lancer_chip(adapter))
 				break;
 
@@ -2941,7 +2941,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
 	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
 				     GFP_KERNEL);
-	if (cmd.va == NULL)
+	if (!cmd.va)
 		return -ENOMEM;
 
 	if (enable) {
@@ -4133,7 +4133,7 @@ lancer_fw_exit:
 static int be_get_ufi_type(struct be_adapter *adapter,
 			   struct flash_file_hdr_g3 *fhdr)
 {
-	if (fhdr == NULL)
+	if (!fhdr)
 		goto be_get_ufi_exit;
 
 	if (skyhawk_chip(adapter) && fhdr->build[0] == '4')
@@ -4475,12 +4475,12 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 
 	if (BEx_chip(adapter) && be_physfn(adapter)) {
 		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
-		if (adapter->csr == NULL)
+		if (!adapter->csr)
 			return -ENOMEM;
 	}
 
 	addr = pci_iomap(adapter->pdev, db_bar(adapter), 0);
-	if (addr == NULL)
+	if (!addr)
 		goto pci_map_err;
 	adapter->db = addr;
 
@@ -4543,7 +4543,7 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	rx_filter->va = dma_zalloc_coherent(&adapter->pdev->dev,
 					    rx_filter->size, &rx_filter->dma,
 					    GFP_KERNEL);
-	if (rx_filter->va == NULL) {
+	if (!rx_filter->va) {
 		status = -ENOMEM;
 		goto free_mbox;
 	}
@@ -4592,7 +4592,7 @@ static int be_stats_init(struct be_adapter *adapter)
 
 	cmd->va = dma_zalloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
 				      GFP_KERNEL);
-	if (cmd->va == NULL)
+	if (!cmd->va)
 		return -ENOMEM;
 	return 0;
 }
@@ -4814,7 +4814,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	pci_set_master(pdev);
 
 	netdev = alloc_etherdev_mqs(sizeof(*adapter), MAX_TX_QS, MAX_RX_QS);
-	if (netdev == NULL) {
+	if (!netdev) {
 		status = -ENOMEM;
 		goto rel_reg;
 	}
-- 
1.7.1
