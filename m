From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/2] NetXen: Firmware check modifications
Date: Mon, 22 Jan 2007 06:38:05 -0800
Message-ID: <200701221438.l0MEc5eM004155@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	linuxram@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:16846 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751723AbXAVOiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 09:38:07 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to make the driver work with multiple minor firmware versions

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---
 netxen_nic.h    |    7 +++----
 netxen_nic_hw.c |    3 ++-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6490acf..663fa2f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,12 +63,11 @@ #include <asm/pgtable.h>
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "4"
+#define NETXEN_NIC_BUILD_NO     "1"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
-#define _NETXEN_NIC_LINUX_SUBVERSION 2
-#define NETXEN_NIC_LINUX_VERSIONID  "3.3.2" "-" NETXEN_NIC_BUILD_NO
-#define NETXEN_NIC_FW_VERSIONID "3.3.2"
+#define _NETXEN_NIC_LINUX_SUBVERSION 3
+#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3" "-" NETXEN_NIC_BUILD_NO
 
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c0c31d1..191e233 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -984,7 +984,8 @@ void netxen_nic_flash_print(struct netxe
 		       _NETXEN_NIC_LINUX_MAJOR, fw_major);
 		adapter->driver_mismatch = 1;
 	}
-	if (fw_minor != _NETXEN_NIC_LINUX_MINOR) {
+	if (fw_minor != _NETXEN_NIC_LINUX_MINOR &&
+			fw_minor != (_NETXEN_NIC_LINUX_MINOR + 1)) {
 		printk(KERN_ERR "The mismatch in driver version and firmware "
 		       "version minor number\n"
 		       "Driver version minor number = %d \t"
