From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/4] enic: Add new fw devcmd to set mac address
	of an interface
Date: Mon, 20 Feb 2012 02:11:53 -0800
Message-ID: <20120220101153.5794.22971.stgit@rhel6.1>
References: <20120220101140.5794.60233.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:20197 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab2BTCR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 21:17:59 -0500
In-Reply-To: <20120220101140.5794.60233.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds a new devcmd CMD_SET_MAC_ADDR to set the mac address of an
interface.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h        |    2 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c    |   12 ++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |    1 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h |    9 +++++++++
 4 files changed, 23 insertions(+), 1 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index f7c3067..06fba32 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.35"
+#define DRV_VERSION		"2.1.1.36"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 79cb340..605b222 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -1023,3 +1023,15 @@ int vnic_dev_deinit_done(struct vnic_dev *vdev, int *status)
 {
 	return vnic_dev_cmd_status(vdev, CMD_DEINIT, status);
 }
+
+int vnic_dev_set_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
+{
+	u64 a0, a1;
+	int wait = 1000;
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		((u8 *)&a0)[i] = mac_addr[i];
+
+	return vnic_dev_cmd(vdev, CMD_SET_MAC_ADDR, &a0, &a1, wait);
+}
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index e476c73..f3d9b79 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -131,5 +131,6 @@ int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len);
 int vnic_dev_enable2(struct vnic_dev *vdev, int active);
 int vnic_dev_enable2_done(struct vnic_dev *vdev, int *status);
 int vnic_dev_deinit_done(struct vnic_dev *vdev, int *status);
+int vnic_dev_set_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
 
 #endif /* _VNIC_DEV_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
index 8a58dea..23d5552 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
@@ -337,6 +337,15 @@ enum vnic_devcmd_cmd {
 	 *      (u32)a2 = maximum timer value in usec
 	 */
 	CMD_INTR_COAL_CONVERT = _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 50),
+
+	/*
+	 * cmd_set_mac_addr
+	 *	set mac address
+	 * in:
+	 *   (u48)a0 = mac addr
+	 *
+	 */
+	CMD_SET_MAC_ADDR = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 55),
 };
 
 /* CMD_ENABLE2 flags */
