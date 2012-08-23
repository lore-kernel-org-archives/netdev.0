From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] vlan: add helper which can be called to se it device is used by vlan
Date: Thu, 23 Aug 2012 15:26:52 +0200
Message-ID: <1345728413-10298-3-git-send-email-jiri@resnulli.us>
References: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, brouer@redhat.com, ogerlitz@mellanox.com,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48515 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933002Ab2HWN1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:27:19 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so400008wey.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 06:27:19 -0700 (PDT)
In-Reply-To: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also, remove unused vlan_info definition from header

CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_vlan.h | 9 +++++++--
 net/8021q/vlan_core.c   | 6 ++++++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a810987..e6ff12d 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -74,8 +74,6 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
-struct vlan_info;
-
 static inline int is_vlan_dev(struct net_device *dev)
 {
         return dev->priv_flags & IFF_802_1Q_VLAN;
@@ -101,6 +99,8 @@ extern int vlan_vids_add_by_dev(struct net_device *dev,
 				const struct net_device *by_dev);
 extern void vlan_vids_del_by_dev(struct net_device *dev,
 				 const struct net_device *by_dev);
+
+extern bool vlan_uses_dev(const struct net_device *dev);
 #else
 static inline struct net_device *
 __vlan_find_dev_deep(struct net_device *real_dev, u16 vlan_id)
@@ -151,6 +151,11 @@ static inline void vlan_vids_del_by_dev(struct net_device *dev,
 					const struct net_device *by_dev)
 {
 }
+
+static inline bool vlan_uses_dev(const struct net_device *dev)
+{
+	return false;
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index d4babc6..517b940 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -372,3 +372,9 @@ void vlan_vids_del_by_dev(struct net_device *dev,
 		vlan_vid_del(dev, vid_info->vid);
 }
 EXPORT_SYMBOL(vlan_vids_del_by_dev);
+
+bool vlan_uses_dev(const struct net_device *dev)
+{
+	return rtnl_dereference(dev->vlan_info) ? true : false;
+}
+EXPORT_SYMBOL(vlan_uses_dev);
-- 
1.7.11.4
