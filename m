From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/6] netxen: add PCI IDs for new chip
Date: Sat, 24 Oct 2009 19:04:00 -0700
Message-ID: <1256436243-5736-4-git-send-email-dhananjay@netxen.com>
References: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1502 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752469AbZJYCEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 22:04:00 -0400
In-Reply-To: <1256436243-5736-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PCI vendor and device IDs for QLE8240 and QLE8242
CNA devices.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |    2 --
 drivers/net/netxen/netxen_nic_ethtool.c |    4 ++--
 drivers/net/netxen/netxen_nic_main.c    |    6 ++++++
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 5ba923b..5d0810f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -74,8 +74,6 @@
 #define NETXEN_FLASH_TOTAL_SIZE  (NETXEN_NUM_FLASH_SECTORS \
 					* NETXEN_FLASH_SECTOR_SIZE)
 
-#define PHAN_VENDOR_ID 0x4040
-
 #define RCV_DESC_RINGSIZE(rds_ring)	\
 	(sizeof(struct rcv_desc) * (rds_ring)->num_desc)
 #define RCV_BUFF_RINGSIZE(rds_ring)	\
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index a3b18e0..c86095e 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -688,8 +688,8 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	u32 data_read, data_written;
 
 	data_read = NXRD32(adapter, NETXEN_PCIX_PH_REG(0));
-	if ((data_read & 0xffff) != PHAN_VENDOR_ID)
-	return 1;
+	if ((data_read & 0xffff) != adapter->pdev->vendor)
+		return 1;
 
 	data_written = (u32)0xa5a5a5a5;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1071f09..e4aa4b4 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -91,6 +91,11 @@ static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
+#define ENTRY2(device) \
+	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
+	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
+
+#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
 
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
@@ -101,6 +106,7 @@ static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT),
 	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT2),
 	ENTRY(PCI_DEVICE_ID_NX3031),
+	ENTRY2(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	{0,}
 };
 
-- 
1.6.0.2

