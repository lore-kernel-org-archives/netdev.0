From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/8] net: dsa: directly fetch switch in lan9303_rcv
Date: Fri, 29 Sep 2017 14:36:29 -0400
Message-ID: <20170929183635.8122-3-vivien.didelot@savoirfairelinux.com>
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
 net/dsa/tag_lan9303.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 0b9826105e42..f0b51acf36ac 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -72,11 +72,10 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	u16 *lan9303_tag;
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_switch *ds = cpu_dp->ds;
 	unsigned int source_port;
 
-	ds = dst->ds[0];
-
 	if (unlikely(!ds)) {
 		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing DSA switch device\n");
 		return NULL;
-- 
2.14.1
