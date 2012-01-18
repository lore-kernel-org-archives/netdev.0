From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/4] enic: This patch adds pci id 0x71 for SRIOV
	VF's
Date: Wed, 18 Jan 2012 06:23:55 -0800
Message-ID: <20120118142355.7877.85730.stgit@rhel6.1>
References: <20120118142336.7877.67031.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:49542 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875Ab2ARGjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:39:55 -0500
In-Reply-To: <20120118142336.7877.67031.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds pci id 0x71 for sriov VF's.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index fe0c29a..ee93a20 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.28"
+#define DRV_VERSION		"2.1.1.31"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 2fd9db4..a634f58 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -57,11 +57,13 @@
 
 #define PCI_DEVICE_ID_CISCO_VIC_ENET         0x0043  /* ethernet vnic */
 #define PCI_DEVICE_ID_CISCO_VIC_ENET_DYN     0x0044  /* enet dynamic vnic */
+#define PCI_DEVICE_ID_CISCO_VIC_ENET_VF      0x0071  /* enet SRIOV VF */
 
 /* Supported devices */
 static DEFINE_PCI_DEVICE_TABLE(enic_id_table) = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET_DYN) },
+	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET_VF) },
 	{ 0, }	/* end of table */
 };
 
@@ -132,6 +134,11 @@ int enic_sriov_enabled(struct enic *enic)
 	return (enic->priv_flags & ENIC_SRIOV_ENABLED) ? 1 : 0;
 }
 
+static int enic_is_sriov_vf(struct enic *enic)
+{
+	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_VF;
+}
+
 int enic_is_valid_vf(struct enic *enic, int vf)
 {
 #ifdef CONFIG_PCI_IOV
