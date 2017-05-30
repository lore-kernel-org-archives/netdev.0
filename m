From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/6] net: dsa: remove unused arguments of tagger rcv
Date: Tue, 30 May 2017 14:33:17 -0400
Message-ID: <20170530183319.10718-5-vivien.didelot@savoirfairelinux.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The struct dsa_device_ops defines the rcv function with 2 unused
arguments struct packet_type *pt, and struct net_device *orig_dev.

This patch removes them from the definition and implementations.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h     | 4 +---
 net/dsa/dsa.c         | 2 +-
 net/dsa/dsa_priv.h    | 4 +---
 net/dsa/tag_brcm.c    | 4 +---
 net/dsa/tag_dsa.c     | 4 +---
 net/dsa/tag_edsa.c    | 4 +---
 net/dsa/tag_lan9303.c | 3 +--
 net/dsa/tag_mtk.c     | 4 +---
 net/dsa/tag_qca.c     | 4 +---
 net/dsa/tag_trailer.c | 4 +---
 10 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4675b52c964c..9e128e447f0b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -129,9 +129,7 @@ struct dsa_switch_tree {
 
 	/* Copy of tag_ops->rcv for faster access in hot path */
 	struct sk_buff *	(*rcv)(struct sk_buff *skb,
-				       struct net_device *dev,
-				       struct packet_type *pt,
-				       struct net_device *orig_dev);
+				       struct net_device *dev);
 
 	/*
 	 * Original copy of the master netdev ethtool_ops
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 3288a80d4d6c..58594784ab94 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -204,7 +204,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
-	nskb = dst->rcv(skb, dev, pt, orig_dev);
+	nskb = dst->rcv(skb, dev);
 	if (!nskb) {
 		kfree_skb(skb);
 		return 0;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2ce9fec9eec5..1a69d70fcd3a 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -67,9 +67,7 @@ struct dsa_notifier_vlan_info {
 
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
-	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev);
+	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev);
 };
 
 struct dsa_slave_priv {
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 9f204f18ada3..c8bff4d7543d 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -92,9 +92,7 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 	return NULL;
 }
 
-static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-				    struct packet_type *pt,
-				    struct net_device *orig_dev)
+static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 3b62a57956a3..41f78e42f9ba 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -68,9 +68,7 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev)
+static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index f95cafd05702..36389fc8fe06 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -81,9 +81,7 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
-				struct packet_type *pt,
-				struct net_device *orig_dev)
+static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index afd59330b5f1..82e150486497 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -71,8 +71,7 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	u16 *lan9303_tag;
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index d1258e84cd71..7c9764c8d61b 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -47,9 +47,7 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 	return NULL;
 }
 
-static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-				   struct packet_type *pt,
-				   struct net_device *orig_dev)
+static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 2451007699b7..d38bd5cbfad8 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -66,9 +66,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NULL;
 }
 
-static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
-				   struct packet_type *pt,
-				   struct net_device *orig_dev)
+static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 7488ab2932ab..e1fd78197fc8 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -58,9 +58,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	return nskb;
 }
 
-static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
-				   struct packet_type *pt,
-				   struct net_device *orig_dev)
+static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
-- 
2.13.0
