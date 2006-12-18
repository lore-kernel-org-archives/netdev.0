From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 4/8] NetXen: Multiple adapter fix.
Date: Mon, 18 Dec 2006 05:52:39 -0800
Message-ID: <200612181352.kBIDqdXv012185@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:6072 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754064AbWLROWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 netxen_nic.h      |    3 +--
 netxen_nic_main.c |   12 ------------
 2 files changed, 1 insertion(+), 14 deletions(-)


diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index b5410be..421a074 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,7 +63,7 @@
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "1"
+#define NETXEN_NIC_BUILD_NO     "2"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
 #define _NETXEN_NIC_LINUX_SUBVERSION 2
@@ -887,7 +887,6 @@ struct netxen_adapter {
 	struct netxen_recv_context recv_ctx[MAX_RCV_CTX];
 
 	int is_up;
-	int number;
 	struct netxen_dummy_dma dummy_dma;
 
 	/* Context interface shared between card and host */
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f2b3fbc..926ead7 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -53,8 +53,6 @@ char netxen_nic_driver_name[] = "netxen-
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
 
-struct netxen_adapter *g_adapter = NULL;
-
 #define NETXEN_NETDEV_WEIGHT 120
 #define NETXEN_ADAPTER_UP_MAGIC 777
 #define NETXEN_NIC_PEG_TUNE 0
@@ -131,7 +129,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	struct netxen_cmd_buffer *cmd_buf_arr = NULL;
 	u64 mac_addr[FLASH_NUM_PORTS + 1];
 	int valid_mac = 0;
-	static int netxen_cards_found = 0;
 
 	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
 	/* In current scheme, we use only PCI function 0 */
@@ -222,9 +219,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		goto err_out_dbunmap;
 	}
 
-	if (netxen_cards_found == 0) {
-		g_adapter = adapter;
-	}
 	adapter->max_tx_desc_count = MAX_CMD_DESCRIPTORS;
 	adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS;
 	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
@@ -468,7 +462,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		break;
 	}
 
-	adapter->number = netxen_cards_found;
 	adapter->driver_mismatch = 0;
 
 	return 0;
@@ -965,11 +958,6 @@ static int netxen_nic_xmit_frame(struct
 static void netxen_watchdog(unsigned long v)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
-	if (adapter != g_adapter) {
-		printk("%s: ***BUG*** adapter[%p] != g_adapter[%p]\n",
-		       __FUNCTION__, adapter, g_adapter);
-		return;
-	}
 
 	SCHEDULE_WORK(&adapter->watchdog_task);
 }
