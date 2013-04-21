From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] net: vlan: fix dummy function signatures for CONFIG_VLAN=n
Date: Sun, 21 Apr 2013 11:51:41 +0200
Message-ID: <1366537901-559-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemlofft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49945 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab3DUJwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 05:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up some function signatures for CONFIG_VLAN=n that were missed during
the 802.1ad support patches.

Found by the kbuild robot.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/if_vlan.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a78f939..52bd03b 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -104,7 +104,8 @@ extern void vlan_vids_del_by_dev(struct net_device *dev,
 extern bool vlan_uses_dev(const struct net_device *dev);
 #else
 static inline struct net_device *
-__vlan_find_dev_deep(struct net_device *real_dev, u16 vlan_id)
+__vlan_find_dev_deep(struct net_device *real_dev,
+		     __be16 vlan_proto, u16 vlan_id)
 {
 	return NULL;
 }
@@ -131,12 +132,12 @@ static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
 	return skb;
 }
 
-static inline int vlan_vid_add(struct net_device *dev, unsigned short vid)
+static inline int vlan_vid_add(struct net_device *dev, __be16 proto, u16 vid)
 {
 	return 0;
 }
 
-static inline void vlan_vid_del(struct net_device *dev, unsigned short vid)
+static inline void vlan_vid_del(struct net_device *dev, __be16 proto, u16 vid)
 {
 }
 
-- 
1.8.1.4
