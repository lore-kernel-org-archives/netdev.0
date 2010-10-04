From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 8/9] qlcnic: cleanup port mode
Date: Mon,  4 Oct 2010 06:45:36 -0700
Message-ID: <1286199938-17367-9-git-send-email-amit.salecha@qlogic.com>
References: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48545 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755941Ab0JDNpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 09:45:45 -0400
In-Reply-To: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Note:Port mode is set by default to Auto neg in firmware.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   40 --------------------------------------
 1 files changed, 0 insertions(+), 40 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index b689d1b..ce830c9 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -46,11 +46,6 @@ char qlcnic_driver_name[] = "qlcnic";
 static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
-static int port_mode = QLCNIC_PORT_MODE_AUTO_NEG;
-
-/* Default to restricted 1G auto-neg mode */
-static int wol_port_mode = 5;
-
 static int qlcnic_mac_learn;
 module_param(qlcnic_mac_learn, int, 0644);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
@@ -264,40 +259,6 @@ static void qlcnic_clear_stats(struct qlcnic_adapter *adapter)
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
 }
 
-static void qlcnic_set_port_mode(struct qlcnic_adapter *adapter)
-{
-	u32 val, data;
-
-	val = adapter->ahw.board_type;
-	if ((val == QLCNIC_BRDTYPE_P3_HMEZ) ||
-		(val == QLCNIC_BRDTYPE_P3_XG_LOM)) {
-		if (port_mode == QLCNIC_PORT_MODE_802_3_AP) {
-			data = QLCNIC_PORT_MODE_802_3_AP;
-			QLCWR32(adapter, QLCNIC_PORT_MODE_ADDR, data);
-		} else if (port_mode == QLCNIC_PORT_MODE_XG) {
-			data = QLCNIC_PORT_MODE_XG;
-			QLCWR32(adapter, QLCNIC_PORT_MODE_ADDR, data);
-		} else if (port_mode == QLCNIC_PORT_MODE_AUTO_NEG_1G) {
-			data = QLCNIC_PORT_MODE_AUTO_NEG_1G;
-			QLCWR32(adapter, QLCNIC_PORT_MODE_ADDR, data);
-		} else if (port_mode == QLCNIC_PORT_MODE_AUTO_NEG_XG) {
-			data = QLCNIC_PORT_MODE_AUTO_NEG_XG;
-			QLCWR32(adapter, QLCNIC_PORT_MODE_ADDR, data);
-		} else {
-			data = QLCNIC_PORT_MODE_AUTO_NEG;
-			QLCWR32(adapter, QLCNIC_PORT_MODE_ADDR, data);
-		}
-
-		if ((wol_port_mode != QLCNIC_PORT_MODE_802_3_AP) &&
-			(wol_port_mode != QLCNIC_PORT_MODE_XG) &&
-			(wol_port_mode != QLCNIC_PORT_MODE_AUTO_NEG_1G) &&
-			(wol_port_mode != QLCNIC_PORT_MODE_AUTO_NEG_XG)) {
-			wol_port_mode = QLCNIC_PORT_MODE_AUTO_NEG;
-		}
-		QLCWR32(adapter, QLCNIC_WOL_PORT_MODE, wol_port_mode);
-	}
-}
-
 static void qlcnic_set_msix_bit(struct pci_dev *pdev, int enable)
 {
 	u32 control;
@@ -1032,7 +993,6 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 	err = qlcnic_pinit_from_rom(adapter);
 	if (err)
 		goto err_out;
-	qlcnic_set_port_mode(adapter);
 
 	err = qlcnic_load_firmware(adapter);
 	if (err)
-- 
1.6.0.2

