From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] net: l3mdev: Remove const from flowi6 arg to get_rt6_dst
Date: Mon, 13 Jun 2016 13:44:17 -0700
Message-ID: <1465850659-27830-2-git-send-email-dsa@cumulusnetworks.com>
References: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36495 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422685AbcFMUoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:44:38 -0400
Received: by mail-pf0-f177.google.com with SMTP id t190so49525720pfb.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 13:44:32 -0700 (PDT)
In-Reply-To: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow drivers to pass flow arg to functions where the arg is not const
and allow the driver to make updates as needed (eg., setting oif).

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 2 +-
 include/net/l3mdev.h | 6 +++---
 net/l3mdev/l3mdev.c  | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b4d746943bc5..d2ce76c9dc64 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -861,7 +861,7 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
-					 const struct flowi6 *fl6)
+					 struct flowi6 *fl6)
 {
 	struct dst_entry *dst = NULL;
 
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 34f33eb96a5e..f8a416ec674c 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -38,7 +38,7 @@ struct l3mdev_ops {
 
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
-						 const struct flowi6 *fl6);
+						 struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -139,7 +139,7 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 
 int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6);
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6);
 
 static inline
 struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
@@ -225,7 +225,7 @@ static inline int l3mdev_get_saddr(struct net *net, int ifindex,
 }
 
 static inline
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6)
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6)
 {
 	return NULL;
 }
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 7da97809a7e8..d90e4ef09e85 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -108,7 +108,7 @@ EXPORT_SYMBOL_GPL(l3mdev_fib_table_by_index);
  */
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
-				     const struct flowi6 *fl6)
+				     struct flowi6 *fl6)
 {
 	struct dst_entry *dst = NULL;
 	struct net_device *dev;
-- 
2.1.4
