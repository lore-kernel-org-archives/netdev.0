From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 4/7] qlcnic: get board name API
Date: Tue,  4 Dec 2012 08:33:55 -0500
Message-ID: <1354628038-2234-5-git-send-email-sony.chacko@qlogic.com>
References: <1354628038-2234-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:40265 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753071Ab2LDNwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 08:52:41 -0500
In-Reply-To: <1354628038-2234-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Cleanup get board information API.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |   26 +---------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   35 ++++++++++++++++++----
 2 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 528d88c..4d85c70 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1444,7 +1444,7 @@ void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *,
  */
 
 #define QLCNIC_MAX_BOARD_NAME_LEN 100
-struct qlcnic_brdinfo {
+struct qlcnic_board_info {
 	unsigned short  vendor;
 	unsigned short  device;
 	unsigned short  sub_vendor;
@@ -1452,30 +1452,6 @@ struct qlcnic_brdinfo {
 	char short_name[QLCNIC_MAX_BOARD_NAME_LEN];
 };
 
-static const struct qlcnic_brdinfo qlcnic_boards[] = {
-	{0x1077, 0x8020, 0x1077, 0x203,
-		"8200 Series Single Port 10GbE Converged Network Adapter "
-		"(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x207,
-		"8200 Series Dual Port 10GbE Converged Network Adapter "
-		"(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x20b,
-		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20c,
-		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20f,
-		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3733,
-		"NC523SFP 10Gb 2-port Server Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3346,
-		"CN1000Q Dual Port Converged Network Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x210,
-		"QME8242-k 10GbE Dual Port Mezzanine Card"},
-	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
-};
-
-#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
-
 static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 {
 	if (likely(tx_ring->producer < tx_ring->sw_consumer))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 80030af..bfcd004 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -118,6 +118,30 @@ static const u32 msi_tgt_status[8] = {
 	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
 };
 
+static const struct qlcnic_board_info qlcnic_boards[] = {
+	{0x1077, 0x8020, 0x1077, 0x203,
+	 "8200 Series Single Port 10GbE Converged Network Adapter"
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x207,
+	 "8200 Series Dual Port 10GbE Converged Network Adapter"
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x20b,
+	 "3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20c,
+	 "3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20f,
+	 "3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3733,
+	 "NC523SFP 10Gb 2-port Server Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3346,
+	 "CN1000Q Dual Port Converged Network Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x210,
+	 "QME8242-k 10GbE Dual Port Mezzanine Card"},
+	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
+};
+
+#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
+
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
@@ -525,7 +549,7 @@ static int qlcnic_setup_pci_map(struct pci_dev *pdev,
 	return 0;
 }
 
-static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
+static void qlcnic_get_board_name(struct qlcnic_adapter *adapter, char *name)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int i, found = 0;
@@ -1467,7 +1491,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_adapter *adapter = NULL;
 	int err, pci_using_dac = -1;
 	uint8_t revision_id;
-	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
+	char board_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1547,11 +1571,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
 	if (adapter->portnum == 0) {
-		get_brd_name(adapter, brd_name);
-
+		qlcnic_get_board_name(adapter, board_name);
 		pr_info("%s: %s Board Chip rev 0x%x\n",
-				module_name(THIS_MODULE),
-				brd_name, adapter->ahw->revision_id);
+			module_name(THIS_MODULE),
+			board_name, adapter->ahw->revision_id);
 	}
 
 	qlcnic_clear_stats(adapter);
-- 
1.7.1
