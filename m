From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 1/4] net-next: dsa: move struct dsa_device_ops to the global header file
Date: Fri, 21 Jul 2017 10:58:10 +0200
Message-ID: <20170721085813.30789-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to access this struct from within the flow_dissector to fix
dissection for packets coming in on DSA devices.

Signed-off-by: John Crispin <john@phrozen.org>
---
 include/net/dsa.h  | 7 +++++++
 net/dsa/dsa_priv.h | 7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 88da272d20d0..a4c0d52abc80 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -101,6 +101,13 @@ struct dsa_platform_data {
 
 struct packet_type;
 
+struct dsa_device_ops {
+	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
+	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt,
+			       struct net_device *orig_dev);
+};
+
 struct dsa_switch_tree {
 	struct list_head	list;
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 55982cc39b24..62ea3663c2c6 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -65,13 +65,6 @@ struct dsa_notifier_vlan_info {
 	int port;
 };
 
-struct dsa_device_ops {
-	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
-	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev);
-};
-
 struct dsa_slave_priv {
 	/* Copy of dp->ds->dst->tag_ops->xmit for faster access in hot path */
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
-- 
2.11.0
