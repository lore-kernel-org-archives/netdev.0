From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 01/10]: Fix off-by-ones in VLAN ID checks
Date: Tue,  5 Jun 2007 16:36:52 +0200 (MEST)
Message-ID: <20070605143651.23717.20253.sendpatchset@localhost.localdomain>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64416 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762779AbXFEOgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:36:54 -0400
In-Reply-To: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Fix off-by-ones in VLAN ID checks

The valid range of VLAN IDs is 0-4095, fix using ID 4095.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 576d73325b7ce3d454c544dcdfea0a2e3ae6486e
tree 2039651421302cf1863cd4b70f502d18a04bc7ac
parent 6a0492fd68c8c5f528e4277bec20bef8047aec2e
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:44 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:44 +0200

 net/8021q/vlan.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ceef57c..f3b1328 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -173,7 +173,7 @@ static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
 	return NULL;
 }
 
-/*  Find the protocol handler.  Assumes VID < VLAN_VID_MASK.
+/*  Find the protocol handler.  Assumes VID <= VLAN_VID_MASK.
  *
  * Must be invoked with RCU read lock (no preempt)
  */
@@ -222,7 +222,7 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 #endif
 
 	/* sanity check */
-	if (vlan_id >= VLAN_VID_MASK)
+	if (vlan_id > VLAN_VID_MASK)
 		return -EINVAL;
 
 	ASSERT_RTNL();
@@ -256,11 +256,11 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 			/* If the group is now empty, kill off the
 			 * group.
 			 */
-			for (i = 0; i < VLAN_VID_MASK; i++)
+			for (i = 0; i <= VLAN_VID_MASK; i++)
 				if (vlan_group_get_device(grp, i))
 					break;
 
-			if (i == VLAN_VID_MASK) {
+			if (i > VLAN_VID_MASK) {
 				if (real_dev->features & NETIF_F_HW_VLAN_RX)
 					real_dev->vlan_rx_register(real_dev, NULL);
 
@@ -392,7 +392,7 @@ static struct net_device *register_vlan_device(const char *eth_IF_name,
 		__FUNCTION__, eth_IF_name, VLAN_ID);
 #endif
 
-	if (VLAN_ID >= VLAN_VID_MASK)
+	if (VLAN_ID > VLAN_VID_MASK)
 		goto out_ret_null;
 
 	/* find the device relating to eth_IF_name. */
