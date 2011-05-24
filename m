From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/2] net: move is_vlan_dev into public header file (v2)
Date: Tue, 24 May 2011 14:31:08 -0400
Message-ID: <1306261869-7276-2-git-send-email-nhorman@tuxdriver.com>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
 <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60547 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab1EXSb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 14:31:28 -0400
In-Reply-To: <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Migrate is_vlan_dev() to if_vlan.h so that core networkig can use it

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: davem@davemloft.net
CC: bhutchings@solarflare.com
---
 include/linux/if_vlan.h |    5 +++++
 net/8021q/vlan.h        |    5 -----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 290bd8a..dc01681 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -110,6 +110,11 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
 }
 
+static inline int is_vlan_dev(struct net_device *dev)
+{
+        return dev->priv_flags & IFF_802_1Q_VLAN;
+}
+
 #define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
 #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index c3408de..9da07e3 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -118,11 +118,6 @@ extern void vlan_netlink_fini(void);
 
 extern struct rtnl_link_ops vlan_link_ops;
 
-static inline int is_vlan_dev(struct net_device *dev)
-{
-	return dev->priv_flags & IFF_802_1Q_VLAN;
-}
-
 extern int vlan_net_id;
 
 struct proc_dir_entry;
-- 
1.7.5.1

