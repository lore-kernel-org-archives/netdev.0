From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 5/6] netxen: module firmware hints
Date: Sat, 24 Oct 2009 19:04:02 -0700
Message-ID: <1256436243-5736-6-git-send-email-dhananjay@netxen.com>
References: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1509 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752481AbZJYCEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 22:04:00 -0400
In-Reply-To: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MODULE_FIRMWARE hints for various firmware file types,
required by different chip revisions.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    6 ++++++
 drivers/net/netxen/netxen_nic_init.c |    6 +++++-
 drivers/net/netxen/netxen_nic_main.c |    4 ++++
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5d0810f..5982dac 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -517,6 +517,12 @@ struct uni_data_desc{
 #define NX_FLASH_ROMIMAGE	4
 #define NX_UNKNOWN_ROMIMAGE	0xff
 
+#define NX_P2_MN_ROMIMAGE_NAME		"nxromimg.bin"
+#define NX_P3_CT_ROMIMAGE_NAME		"nx3fwct.bin"
+#define NX_P3_MN_ROMIMAGE_NAME		"nx3fwmn.bin"
+#define NX_UNIFIED_ROMIMAGE_NAME	"phanfw.bin"
+#define NX_FLASH_ROMIMAGE_NAME		"flash"
+
 extern char netxen_nic_driver_name[];
 
 /* Number of status descriptors to handle per interrupt */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 5f96045..bc80aa3 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -826,7 +826,11 @@ netxen_need_fw_reset(struct netxen_adapter *adapter)
 }
 
 static char *fw_name[] = {
-	"nxromimg.bin", "nx3fwct.bin", "nx3fwmn.bin", "phanfw.bin", "flash",
+	NX_P2_MN_ROMIMAGE_NAME,
+	NX_P3_CT_ROMIMAGE_NAME,
+	NX_P3_MN_ROMIMAGE_NAME,
+	NX_UNIFIED_ROMIMAGE_NAME,
+	NX_FLASH_ROMIMAGE_NAME,
 };
 
 int
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 3861da9..302a58e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -38,6 +38,10 @@
 MODULE_DESCRIPTION("QLogic/NetXen (1/10) GbE Converged Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
+MODULE_FIRMWARE(NX_P2_MN_ROMIMAGE_NAME);
+MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
+MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);
+MODULE_FIRMWARE(NX_UNIFIED_ROMIMAGE_NAME);
 
 char netxen_nic_driver_name[] = "netxen_nic";
 static char netxen_nic_driver_string[] = "QLogic/NetXen Network Driver v"
-- 
1.6.0.2

