From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 1/5] net: dsa: comment hot path requirements
Date: Thu,  1 Jun 2017 16:07:11 -0400
Message-ID: <20170601200715.8438-2-vivien.didelot@savoirfairelinux.com>
References: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA layer uses inline helpers and copy of the tagging functions for
faster access in hot path. Add comments to detail that.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  | 3 +++
 net/dsa/dsa_priv.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7de1234ba136..18ca0a935c96 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -127,6 +127,8 @@ struct dsa_switch_tree {
 	 * protocol to use.
 	 */
 	struct net_device	*master_netdev;
+
+	/* Copy of tag_ops->rcv for faster access in hot path */
 	struct sk_buff *	(*rcv)(struct sk_buff *skb,
 				       struct net_device *dev,
 				       struct packet_type *pt,
@@ -465,6 +467,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 struct net_device *dsa_dev_to_net_device(struct device *dev);
 
+/* Keep inline for faster access in hot path */
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
 	return dst->rcv != NULL;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7459d5735d8b..db2a7b9edfb8 100644
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
