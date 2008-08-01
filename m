From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 7/7] netxen: update driver version
Date: Fri,  1 Aug 2008 03:15:01 -0700
Message-ID: <1217585701-13958-8-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:42830 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753194AbYHAKPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:15:06 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raise driver version to 4.0.6.

Prevent enabling development revisions of the chip between 0x30 to 0x40.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 ++--
 drivers/net/netxen/netxen_nic_hw.c   |    8 ++++----
 drivers/net/netxen/netxen_nic_main.c |    7 +++++++
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index de877ff..0ec62da 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -65,8 +65,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 0
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.0"
+#define _NETXEN_NIC_LINUX_SUBVERSION 6
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.6"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 16) + ((b) << 8) + (c))
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index d6d3b20..e304482 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2206,10 +2206,10 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	if (adapter->portnum == 0) {
 		get_brd_name_by_type(board_info->board_type, brd_name);
 
-		printk("NetXen %s Board S/N %s  Chip id 0x%x\n",
-				brd_name, serial_num, board_info->chip_id);
-		printk("NetXen Firmware version %d.%d.%d\n", fw_major,
-				fw_minor, fw_build);
+		printk(KERN_INFO "NetXen %s Board S/N %s  Chip rev 0x%x\n",
+				brd_name, serial_num, adapter->ahw.revision_id);
+		printk(KERN_INFO "NetXen Firmware version %d.%d.%d\n",
+				fw_major, fw_minor, fw_build);
 	}
 
 	if (NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build) <
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index ecb26f9..e1f6478 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -579,6 +579,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENODEV;
 	}
 
+	if (pdev->revision >= NX_P3_A0 && pdev->revision < NX_P3_B1) {
+		printk(KERN_WARNING "NetXen chip revisions between 0x%x-0x%x"
+				"will not be enabled.\n",
+				NX_P3_A0, NX_P3_B1);
+		return -ENODEV;
+	}
+
 	if ((err = pci_enable_device(pdev)))
 		return err;
 
-- 
1.5.4.3

