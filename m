From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 07/19] qlcnic: get board name API
Date: Wed, 19 Sep 2012 19:46:01 -0400
Message-ID: <1348098373-20745-8-git-send-email-sony.chacko@qlogic.com>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:14387 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753313Ab2ITAMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 20:12:19 -0400
In-Reply-To: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |   26 +----------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   34 ++++++++++++++++++---
 2 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index a50219b..b68ea92 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1567,7 +1567,7 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
  */
 
 #define QLCNIC_MAX_BOARD_NAME_LEN 100
-struct qlcnic_brdinfo {
+struct qlcnic_board_info {
 	unsigned short  vendor;
 	unsigned short  device;
 	unsigned short  sub_vendor;
@@ -1575,30 +1575,6 @@ struct qlcnic_brdinfo {
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
index 615bacb..9076f49 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -163,6 +163,30 @@ static const u32 qlcnic_reg_tbl[] = {
 	0x13C014, /* flash unlock */
 };
 
+static const struct qlcnic_board_info qlcnic_boards[] = {
+	{0x1077, 0x8020, 0x1077, 0x203,
+		"8200 Series Single Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x207,
+		"8200 Series Dual Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x20b,
+		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20c,
+		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20f,
+		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3733,
+		"NC523SFP 10Gb 2-port Server Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3346,
+		"CN1000Q Dual Port Converged Network Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x210,
+		"QME8242-k 10GbE Dual Port Mezzanine Card"},
+	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
+};
+
+#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
+
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
@@ -677,7 +701,7 @@ qlcnic_setup_pci_map(struct pci_dev *pdev,
 	return 0;
 }
 
-static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
+static void qlcnic_get_board_name(struct qlcnic_adapter *adapter, char *name)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int i, found = 0;
@@ -1602,7 +1626,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_hardware_context *ahw;
 	int err;
 	uint8_t pci_using_dac;
-	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
+	char board_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1683,11 +1707,11 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
 	if (adapter->portnum == 0) {
-		get_brd_name(adapter, brd_name);
+		qlcnic_get_board_name(adapter, board_name);
 
 		pr_info("%s: %s Board Chip rev 0x%x\n",
-				module_name(THIS_MODULE),
-				brd_name, adapter->ahw->revision_id);
+			module_name(THIS_MODULE),
+			board_name, adapter->ahw->revision_id);
 	}
 	err = qlcnic_setup_intr(adapter, 0);
 	if (err)
-- 
1.7.1
