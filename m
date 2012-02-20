From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/4] enic: rename CMD_MAC_ADDR to CMD_GET_MAC_ADDR
Date: Mon, 20 Feb 2012 02:11:48 -0800
Message-ID: <20120220101148.5794.23819.stgit@rhel6.1>
References: <20120220101140.5794.60233.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:36102 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab2BTCRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 21:17:54 -0500
In-Reply-To: <20120220101140.5794.60233.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

firmware devcmd CMD_MAC_ADDR gets the mac address of a vnic from adapter.
This patch renames it to CMD_GET_MAC_ADDR more appropriately.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_res.c    |    2 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c    |    6 +++---
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |    2 +-
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic_res.c b/drivers/net/ethernet/cisco/enic/enic_res.c
index 4a35367..31d6588 100644
--- a/drivers/net/ethernet/cisco/enic/enic_res.c
+++ b/drivers/net/ethernet/cisco/enic/enic_res.c
@@ -44,7 +44,7 @@ int enic_get_vnic_config(struct enic *enic)
 	struct vnic_enet_config *c = &enic->config;
 	int err;
 
-	err = vnic_dev_mac_addr(enic->vdev, enic->mac_addr);
+	err = vnic_dev_get_mac_addr(enic->vdev, enic->mac_addr);
 	if (err) {
 		dev_err(enic_get_dev(enic),
 			"Error getting MAC addr, %d\n", err);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 298ad6f..79cb340 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -613,7 +613,7 @@ int vnic_dev_hang_notify(struct vnic_dev *vdev)
 	return vnic_dev_cmd(vdev, CMD_HANG_NOTIFY, &a0, &a1, wait);
 }
 
-int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
+int vnic_dev_get_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
 {
 	u64 a0, a1;
 	int wait = 1000;
@@ -622,7 +622,7 @@ int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
 	for (i = 0; i < ETH_ALEN; i++)
 		mac_addr[i] = 0;
 
-	err = vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
+	err = vnic_dev_cmd(vdev, CMD_GET_MAC_ADDR, &a0, &a1, wait);
 	if (err)
 		return err;
 
@@ -803,7 +803,7 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 			/* Emulate these for old CMD_INIT_v1 which
 			 * didn't pass a0 so no CMD_INITF_*.
 			 */
-			vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
+			vnic_dev_cmd(vdev, CMD_GET_MAC_ADDR, &a0, &a1, wait);
 			vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 		}
 	}
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index 6a138b6..e476c73 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -97,7 +97,7 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti);
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
-int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
+int vnic_dev_get_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
 int vnic_dev_notify_unset(struct vnic_dev *vdev);
 int vnic_dev_link_status(struct vnic_dev *vdev);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
index 8025e88..8a58dea 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
@@ -131,7 +131,7 @@ enum vnic_devcmd_cmd {
 	CMD_HANG_NOTIFY         = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 8),
 
 	/* MAC address in (u48)a0 */
-	CMD_MAC_ADDR            = _CMDC(_CMD_DIR_READ,
+	CMD_GET_MAC_ADDR        = _CMDC(_CMD_DIR_READ,
 					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 9),
 
 	/* add addr from (u48)a0 */
