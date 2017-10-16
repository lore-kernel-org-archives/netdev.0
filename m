From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 5/7] net: dsa: rename dsa_master_get_slave
Date: Mon, 16 Oct 2017 11:12:17 -0400
Message-ID: <20171016151219.22023-6-vivien.didelot@savoirfairelinux.com>
References: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_master_get_slave is slightly confusing since the idiomatic "get"
term often suggests reference counting, in symmetry to "put".

Rename it to dsa_master_find_slave to make the look up operation clear.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h    | 4 ++--
 net/dsa/tag_brcm.c    | 2 +-
 net/dsa/tag_dsa.c     | 2 +-
 net/dsa/tag_edsa.c    | 2 +-
 net/dsa/tag_ksz.c     | 2 +-
 net/dsa/tag_lan9303.c | 2 +-
 net/dsa/tag_mtk.c     | 2 +-
 net/dsa/tag_qca.c     | 2 +-
 net/dsa/tag_trailer.c | 2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index eedda1f1b099..623c22b75e81 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -113,8 +113,8 @@ int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 int dsa_master_ethtool_setup(struct net_device *dev);
 void dsa_master_ethtool_restore(struct net_device *dev);
 
-static inline struct net_device *dsa_master_get_slave(struct net_device *dev,
-						      int device, int port)
+static inline struct net_device *dsa_master_find_slave(struct net_device *dev,
+						       int device, int port)
 {
 	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch_tree *dst = cpu_dp->dst;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 2a0fa9f9f7ca..9e082bae3cb0 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -119,7 +119,7 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* Locate which port this is coming from */
 	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
 
-	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	skb->dev = dsa_master_find_slave(dev, 0, source_port);
 	if (!skb->dev)
 		return NULL;
 
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index fe3c9700a8c8..dbbcdafed8c3 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -91,7 +91,7 @@ static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	source_device = dsa_header[0] & 0x1f;
 	source_port = (dsa_header[1] >> 3) & 0x1f;
 
-	skb->dev = dsa_master_get_slave(dev, source_device, source_port);
+	skb->dev = dsa_master_find_slave(dev, source_device, source_port);
 	if (!skb->dev)
 		return NULL;
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index c683e240bafc..f38a626b3a05 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -104,7 +104,7 @@ static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	source_device = edsa_header[0] & 0x1f;
 	source_port = (edsa_header[1] >> 3) & 0x1f;
 
-	skb->dev = dsa_master_get_slave(dev, source_device, source_port);
+	skb->dev = dsa_master_find_slave(dev, source_device, source_port);
 	if (!skb->dev)
 		return NULL;
 
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index 66e443fd7675..0f62effad88f 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -87,7 +87,7 @@ static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	source_port = tag[0] & 7;
 
-	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	skb->dev = dsa_master_find_slave(dev, 0, source_port);
 	if (!skb->dev)
 		return NULL;
 
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index c709adb5efd9..57519597c6fc 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -94,7 +94,7 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	source_port = ntohs(lan9303_tag[1]) & 0x3;
 
-	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	skb->dev = dsa_master_find_slave(dev, 0, source_port);
 	if (!skb->dev) {
 		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid source port\n");
 		return NULL;
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 5abebbfd7060..8475434af7d5 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -69,7 +69,7 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* Get source port information */
 	port = (hdr & MTK_HDR_RECV_SOURCE_PORT_MASK);
 
-	skb->dev = dsa_master_get_slave(dev, 0, port);
+	skb->dev = dsa_master_find_slave(dev, 0, port);
 	if (!skb->dev)
 		return NULL;
 
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index b0274b6781cb..613f4ee97771 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -91,7 +91,7 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* Get source port information */
 	port = (hdr & QCA_HDR_RECV_SOURCE_PORT_MASK);
 
-	skb->dev = dsa_master_get_slave(dev, 0, port);
+	skb->dev = dsa_master_find_slave(dev, 0, port);
 	if (!skb->dev)
 		return NULL;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 8b205bb5f521..7d20e1f3de28 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -71,7 +71,7 @@ static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	source_port = trailer[1] & 7;
 
-	skb->dev = dsa_master_get_slave(dev, 0, source_port);
+	skb->dev = dsa_master_find_slave(dev, 0, source_port);
 	if (!skb->dev)
 		return NULL;
 
-- 
2.14.2
