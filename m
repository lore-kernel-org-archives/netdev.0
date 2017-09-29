From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/8] net: dsa: directly fetch switch in mtk_tag_rcv
Date: Fri, 29 Sep 2017 14:36:28 -0400
Message-ID: <20170929183635.8122-2-vivien.didelot@savoirfairelinux.com>
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

In a single-chip switch fabric, there is no need to fetch the dsa_switch
structure from the tree, directly use the CPU port's "ds" member.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/tag_mtk.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index ec8ee5f43255..ef0364b82241 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -47,7 +47,8 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_switch *ds = cpu_dp->ds;
 	int port;
 	__be16 *phdr, hdr;
 
@@ -68,14 +69,6 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 		skb->data - ETH_HLEN - MTK_HDR_LEN,
 		2 * ETH_ALEN);
 
-	/* This protocol doesn't support cascading multiple
-	 * switches so it's safe to assume the switch is first
-	 * in the tree.
-	 */
-	ds = dst->ds[0];
-	if (!ds)
-		return NULL;
-
 	/* Get source port information */
 	port = (hdr & MTK_HDR_RECV_SOURCE_PORT_MASK);
 	if (!ds->ports[port].netdev)
-- 
2.14.1
