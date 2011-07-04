From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: vxge: Use is_multicast_ether_addr helper
Date: Mon,  4 Jul 2011 11:58:04 +0200
Message-ID: <1309773484-27514-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:43145 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756944Ab1GDJ6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:58:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/vxge/vxge-main.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 1c92af3..15d878b 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -684,8 +684,7 @@ static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
 	new_mac_entry->state = mac->state;
 	vpath->mac_addr_cnt++;
 
-	/* Is this a multicast address */
-	if (0x01 & mac->macaddr[0])
+	if (is_multicast_ether_addr(mac->macaddr))
 		vpath->mcast_addr_cnt++;
 
 	return TRUE;
@@ -699,7 +698,7 @@ vxge_add_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
 	struct vxge_vpath *vpath;
 	enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
 
-	if (0x01 & mac->macaddr[0]) /* multicast address */
+	if (is_multicast_ether_addr(mac->macaddr))
 		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
 	else
 		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
@@ -1078,8 +1077,7 @@ static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
 			kfree((struct vxge_mac_addrs *)entry);
 			vpath->mac_addr_cnt--;
 
-			/* Is this a multicast address */
-			if (0x01 & mac->macaddr[0])
+			if (is_multicast_ether_addr(mac->macaddr))
 				vpath->mcast_addr_cnt--;
 			return TRUE;
 		}
@@ -1201,8 +1199,7 @@ static void vxge_set_multicast(struct net_device *dev)
 				mac_address = (u8 *)&mac_entry->macaddr;
 				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
 
-				/* Is this a multicast address */
-				if (0x01 & mac_info.macaddr[0]) {
+				if (is_multicast_ether_addr(mac_info.macaddr)) {
 					for (vpath_idx = 0; vpath_idx <
 						vdev->no_of_vpath;
 						vpath_idx++) {
@@ -1244,8 +1241,7 @@ _set_all_mcast:
 				mac_address = (u8 *)&mac_entry->macaddr;
 				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
 
-				/* Is this a multicast address */
-				if (0x01 & mac_info.macaddr[0])
+				if (is_multicast_ether_addr(mac_info.macaddr))
 					break;
 			}
 
-- 
1.7.5.4

