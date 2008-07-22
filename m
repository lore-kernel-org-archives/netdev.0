From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [RESENDv2 11/11] netxen: update driver version
Date: Mon, 21 Jul 2008 19:44:10 -0700
Message-ID: <1216694650-23257-12-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:47605 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754971AbYGVCoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 22:44:12 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change driver version to 4.0.0. Netxen firmwares as old as
v3.4.216 are supported.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h    |   10 ++++++----
 drivers/net/netxen/netxen_nic_hw.c |   14 +++++---------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index bcc551e..ac710c3 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,10 +63,12 @@
 
 #include "netxen_nic_hw.h"
 
-#define _NETXEN_NIC_LINUX_MAJOR 3
-#define _NETXEN_NIC_LINUX_MINOR 4
-#define _NETXEN_NIC_LINUX_SUBVERSION 18
-#define NETXEN_NIC_LINUX_VERSIONID  "3.4.18"
+#define _NETXEN_NIC_LINUX_MAJOR 4
+#define _NETXEN_NIC_LINUX_MINOR 0
+#define _NETXEN_NIC_LINUX_SUBVERSION 0
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.0"
+
+#define NETXEN_VERSION_CODE(a, b, c)	(((a) << 16) + ((b) << 8) + (c))
 
 #define NETXEN_NUM_FLASH_SECTORS (64)
 #define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index ed8aa5a..96a3bc6 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2168,16 +2168,12 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 				fw_minor, fw_build);
 	}
 
-	if (fw_major != _NETXEN_NIC_LINUX_MAJOR) {
+	if (NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build) <
+			NETXEN_VERSION_CODE(3, 4, 216)) {
 		adapter->driver_mismatch = 1;
-	}
-	if (fw_minor != _NETXEN_NIC_LINUX_MINOR &&
-			fw_minor != (_NETXEN_NIC_LINUX_MINOR + 1)) {
-		adapter->driver_mismatch = 1;
-	}
-	if (adapter->driver_mismatch) {
-		printk(KERN_ERR "%s: driver and firmware version mismatch\n",
-				adapter->netdev->name);
+		printk(KERN_ERR "%s: firmware version %d.%d.%d unsupported\n",
+				netxen_nic_driver_name,
+				fw_major, fw_minor, fw_build);
 		return;
 	}
 }
-- 
1.5.4.3

