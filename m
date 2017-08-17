From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] dsa: remove unused net_device arg from handlers
Date: Thu, 17 Aug 2017 16:47:00 +0200
Message-ID: <20170817144700.16218-1-fw@strlen.de>
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56490 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751149AbdHQO5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 10:57:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

compile tested only, but saw no warnings/errors with
allmodconfig build.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/dsa.h     | 6 ++----
 net/dsa/dsa.c         | 4 ++--
 net/dsa/tag_brcm.c    | 3 +--
 net/dsa/tag_dsa.c     | 3 +--
 net/dsa/tag_edsa.c    | 3 +--
 net/dsa/tag_ksz.c     | 3 +--
 net/dsa/tag_lan9303.c | 2 +-
 net/dsa/tag_mtk.c     | 3 +--
 net/dsa/tag_qca.c     | 3 +--
 net/dsa/tag_trailer.c | 3 +--
 10 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7f46b521313e..398ca8d70ccd 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -104,8 +104,7 @@ struct packet_type;
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev);
+			       struct packet_type *pt);
 	int (*flow_dissect)(const struct sk_buff *skb, __be16 *proto,
 			    int *offset);
 };
@@ -134,8 +133,7 @@ struct dsa_switch_tree {
 	/* Copy of tag_ops->rcv for faster access in hot path */
 	struct sk_buff *	(*rcv)(struct sk_buff *skb,
 				       struct net_device *dev,
-				       struct packet_type *pt,
-				       struct net_device *orig_dev);
+				       struct packet_type *pt);
 
 	/*
 	 * The switch port to which the CPU is attached.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 99e38af85fc5..03c58b0eb082 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -186,7 +186,7 @@ struct net_device *dsa_dev_to_net_device(struct device *dev)
 EXPORT_SYMBOL_GPL(dsa_dev_to_net_device);
 
 static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
-			  struct packet_type *pt, struct net_device *orig_dev)
+			  struct packet_type *pt, struct net_device *unused)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct sk_buff *nskb = NULL;
@@ -202,7 +202,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
-	nskb = dst->rcv(skb, dev, pt, orig_dev);
+	nskb = dst->rcv(skb, dev, pt);
 	if (!nskb) {
 		kfree_skb(skb);
 		return 0;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index c697d9815177..de74c3f77818 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -89,8 +89,7 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 }
 
 static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-				    struct packet_type *pt,
-				    struct net_device *orig_dev)
+				    struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 12867a4b458f..fbf9ca954773 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -65,8 +65,7 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev)
+			       struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 67a9d26f9075..76367ba1b2e2 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -78,8 +78,7 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
-				struct packet_type *pt,
-				struct net_device *orig_dev)
+				struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index de66ca8e6201..17f30675c15c 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -76,8 +76,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev)
+			       struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index e23e7635fa00..0b9826105e42 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -68,7 +68,7 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pt, struct net_device *orig_dev)
+			struct packet_type *pt)
 {
 	u16 *lan9303_tag;
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 02163c045a96..ec8ee5f43255 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -44,8 +44,7 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 }
 
 static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-				   struct packet_type *pt,
-				   struct net_device *orig_dev)
+				   struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 1867a3d11f28..1d4c70711c0f 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -63,8 +63,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-				   struct packet_type *pt,
-				   struct net_device *orig_dev)
+				   struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b09e56214005..8707157dea32 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -56,8 +56,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
-				   struct packet_type *pt,
-				   struct net_device *orig_dev)
+				   struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
-- 
2.13.0
