From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 4/6] netxen: update module info
Date: Sat, 24 Oct 2009 19:04:01 -0700
Message-ID: <1256436243-5736-5-git-send-email-dhananjay@netxen.com>
References: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1504 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752474AbZJYCEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 22:04:00 -0400
In-Reply-To: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update module info with QLogic signature.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e4aa4b4..3861da9 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -35,12 +35,12 @@
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
 
-MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
+MODULE_DESCRIPTION("QLogic/NetXen (1/10) GbE Converged Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
 
 char netxen_nic_driver_name[] = "netxen_nic";
-static char netxen_nic_driver_string[] = "NetXen Network Driver version "
+static char netxen_nic_driver_string[] = "QLogic/NetXen Network Driver v"
     NETXEN_NIC_LINUX_VERSIONID;
 
 static int port_mode = NETXEN_PORT_MODE_AUTO_NEG;
@@ -54,7 +54,6 @@ static int use_msi_x = 1;
 
 static unsigned long auto_fw_reset = AUTO_FW_RESET_ENABLED;
 
-/* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
 static void __devexit netxen_nic_remove(struct pci_dev *pdev);
@@ -730,7 +729,8 @@ netxen_check_options(struct netxen_adapter *adapter)
 	if (adapter->portnum == 0) {
 		get_brd_name_by_type(adapter->ahw.board_type, brd_name);
 
-		printk(KERN_INFO "NetXen %s Board S/N %s  Chip rev 0x%x\n",
+		pr_info("%s: %s Board S/N %s  Chip rev 0x%x\n",
+				module_name(THIS_MODULE),
 				brd_name, serial_num, adapter->ahw.revision_id);
 	}
 
@@ -1212,16 +1212,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
 
-	if (pdev->class != 0x020000) {
-		printk(KERN_DEBUG "NetXen function %d, class %x will not "
-				"be enabled.\n",pci_func_id, pdev->class);
-		return -ENODEV;
-	}
-
 	if (pdev->revision >= NX_P3_A0 && pdev->revision < NX_P3_B1) {
-		printk(KERN_WARNING "NetXen chip revisions between 0x%x-0x%x"
+		pr_warning("%s: chip revisions between 0x%x-0x%x"
 				"will not be enabled.\n",
-				NX_P3_A0, NX_P3_B1);
+				module_name(THIS_MODULE), NX_P3_A0, NX_P3_B1);
 		return -ENODEV;
 	}
 
-- 
1.6.0.2

