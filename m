From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 8/8] net: dsa: remove tag ops from the switch tree
Date: Fri, 29 Sep 2017 14:36:35 -0400
Message-ID: <20170929183635.8122-9-vivien.didelot@savoirfairelinux.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the dsa_ptr is a dsa_port instance, there is no need to keep
the tag operations in the dsa_switch_tree structure. Remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 11 -----------
 net/dsa/dsa2.c    |  2 --
 net/dsa/legacy.c  |  2 --
 3 files changed, 15 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 75dc4024f5a8..bf1006f7c0aa 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -130,11 +130,6 @@ struct dsa_switch_tree {
 	 */
 	struct dsa_platform_data	*pd;
 
-	/* Copy of tag_ops->rcv for faster access in hot path */
-	struct sk_buff *	(*rcv)(struct sk_buff *skb,
-				       struct net_device *dev,
-				       struct packet_type *pt);
-
 	/*
 	 * The switch port to which the CPU is attached.
 	 */
@@ -144,12 +139,6 @@ struct dsa_switch_tree {
 	 * Data for the individual switch chips.
 	 */
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
-
-	/*
-	 * Tagging protocol operations for adding and removing an
-	 * encapsulation tag.
-	 */
-	const struct dsa_device_ops *tag_ops;
 };
 
 /* TC matchall action types, only mirroring for now */
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 62302558f38c..54ed054777bd 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -523,11 +523,9 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	}
 
 	dst->cpu_dp->tag_ops = tag_ops;
-	dst->tag_ops = tag_ops;
 
 	/* Make a few copies for faster access in master receive hot path */
 	dst->cpu_dp->rcv = dst->cpu_dp->tag_ops->rcv;
-	dst->rcv = dst->tag_ops->rcv;
 	dst->cpu_dp->dst = dst;
 
 	return 0;
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 71917505a5cc..19ff6e0a21dc 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -153,11 +153,9 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 			return PTR_ERR(tag_ops);
 
 		dst->cpu_dp->tag_ops = tag_ops;
-		dst->tag_ops = tag_ops;
 
 		/* Few copies for faster access in master receive hot path */
 		dst->cpu_dp->rcv = dst->cpu_dp->tag_ops->rcv;
-		dst->rcv = dst->tag_ops->rcv;
 		dst->cpu_dp->dst = dst;
 	}
 
-- 
2.14.1
