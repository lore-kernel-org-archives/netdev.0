From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 1/1] qed: Fix error in the dcbx app meta data initialization.
Date: Mon, 24 Apr 2017 20:59:10 -0700
Message-ID: <20170425035910.29296-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0070.outbound.protection.outlook.com ([104.47.34.70]:32683
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S980370AbdDYD7c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 23:59:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCBX app_data array is initialized with the incorrect values for
personality field. This would  prevent offloaded protocols from
honoring the PFC.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index a6e2bbe..cfdadb6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -64,11 +64,11 @@
 	((u32)(prio_tc_tbl >> ((7 - prio) * 4)) & 0x7)
 
 static const struct qed_dcbx_app_metadata qed_dcbx_app_update[] = {
-	{DCBX_PROTOCOL_ISCSI, "ISCSI", QED_PCI_DEFAULT},
-	{DCBX_PROTOCOL_FCOE, "FCOE", QED_PCI_DEFAULT},
-	{DCBX_PROTOCOL_ROCE, "ROCE", QED_PCI_DEFAULT},
-	{DCBX_PROTOCOL_ROCE_V2, "ROCE_V2", QED_PCI_DEFAULT},
-	{DCBX_PROTOCOL_ETH, "ETH", QED_PCI_ETH}
+	{DCBX_PROTOCOL_ISCSI, "ISCSI", QED_PCI_ISCSI},
+	{DCBX_PROTOCOL_FCOE, "FCOE", QED_PCI_FCOE},
+	{DCBX_PROTOCOL_ROCE, "ROCE", QED_PCI_ETH_ROCE},
+	{DCBX_PROTOCOL_ROCE_V2, "ROCE_V2", QED_PCI_ETH_ROCE},
+	{DCBX_PROTOCOL_ETH, "ETH", QED_PCI_ETH},
 };
 
 static bool qed_dcbx_app_ethtype(u32 app_info_bitmap)
-- 
1.8.3.1
