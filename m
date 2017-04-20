From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Remove redundant NULL dst check
Date: Thu, 20 Apr 2017 15:47:22 -0700
Message-ID: <20170420224723.6916-1-f.fainelli@gmail.com>
Cc: jbe@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tag_lan9303.c does check for a NULL dst but that's already checked by
dsa_switch_rcv() one layer above.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_lan9303.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 563b6c8fe445..70130ed5c21a 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -79,11 +79,6 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct dsa_switch *ds;
 	unsigned int source_port;
 
-	if (unlikely(!dst)) {
-		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing switch tree device\n");
-		return NULL;
-	}
-
 	ds = dst->ds[0];
 
 	if (unlikely(!ds)) {
-- 
2.9.3
