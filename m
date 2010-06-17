From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/5] qlcnic: change driver description
Date: Thu, 17 Jun 2010 05:56:39 -0700
Message-ID: <1276779402-496-3-git-send-email-amit.salecha@qlogic.com>
References: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:64004 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751040Ab0FQM4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 08:56:43 -0400
In-Reply-To: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

o Remove extra printing of mac address
o This driver also supports NIC only Qlogic adapters.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c  |    5 ++---
 drivers/net/qlcnic/qlcnic_main.c |    8 ++++----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 42feb23..90ed6fb 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -589,11 +589,10 @@ int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 			0,
 			QLCNIC_CDRP_CMD_MAC_ADDRESS);
 
-	if (err == QLCNIC_RCODE_SUCCESS) {
+	if (err == QLCNIC_RCODE_SUCCESS)
 		qlcnic_fetch_mac(adapter, QLCNIC_ARG1_CRB_OFFSET,
 				QLCNIC_ARG2_CRB_OFFSET, 0, mac);
-		dev_info(&adapter->pdev->dev, "MAC address: %pM\n", mac);
-	} else {
+	else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get mac address%d\n", err);
 		err = -EIO;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 128a0a7..28ed28c 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -35,14 +35,14 @@
 #include <linux/inetdevice.h>
 #include <linux/sysfs.h>
 
-MODULE_DESCRIPTION("QLogic 10 GbE Converged Ethernet Driver");
+MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(QLCNIC_LINUX_VERSIONID);
 MODULE_FIRMWARE(QLCNIC_UNIFIED_ROMIMAGE_NAME);
 
 char qlcnic_driver_name[] = "qlcnic";
-static const char qlcnic_driver_string[] = "QLogic Converged Ethernet Driver v"
-    QLCNIC_LINUX_VERSIONID;
+static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
+	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
 static int port_mode = QLCNIC_PORT_MODE_AUTO_NEG;
 
@@ -661,7 +661,7 @@ static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
 	}
 
 	if (!found)
-		name = "Unknown";
+		sprintf(name, "%pM Gigabit Ethernet", adapter->mac_addr);
 }
 
 static void
-- 
1.6.0.2

