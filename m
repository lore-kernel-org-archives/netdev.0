From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/6] net: dsa: comment hot path requirements
Date: Tue, 30 May 2017 14:33:14 -0400
Message-ID: <20170530183319.10718-2-vivien.didelot@savoirfairelinux.com>
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

The DSA layer uses inline helpers and copies of the tagging functions
for faster access in hot path. Add comments to detail that.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  | 3 +++
 net/dsa/dsa_priv.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c0e567c0c824..58297e4c6b31 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -126,6 +126,8 @@ struct dsa_switch_tree {
 	 * protocol to use.
 	 */
 	struct net_device	*master_netdev;
+
+	/* Copy of tag_ops->rcv for faster access in hot path */
 	struct sk_buff *	(*rcv)(struct sk_buff *skb,
 				       struct net_device *dev,
 				       struct packet_type *pt,
@@ -464,6 +466,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 struct net_device *dsa_dev_to_net_device(struct device *dev);
 
+/* Keep inline for faster access in hot path */
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
 	return dst->rcv != NULL;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c1d4180651af..2ce9fec9eec5 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -73,6 +73,7 @@ struct dsa_device_ops {
 };
 
 struct dsa_slave_priv {
+	/* Copy of dp->ds->dst->tag_ops->xmit for faster access in hot path */
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
-- 
2.13.0
