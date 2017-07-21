From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 4/4] net-next: tag_mtk: add nh and proto offsets to the ops struct
Date: Fri, 21 Jul 2017 10:58:13 +0200
Message-ID: <20170721085813.30789-4-john@phrozen.org>
References: <20170721085813.30789-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721085813.30789-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MT7530 inserts the 4 magic header in between the 802.3 address and
protocol field. The patch defines these header such that the flow_disector
can properly parse the packet and thus allows hashing to function properly.

Signed-off-by: John Crispin <john@phrozen.org>
---
 net/dsa/tag_mtk.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 2f32b7ea3365..142322988202 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -88,6 +88,8 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 }
 
 const struct dsa_device_ops mtk_netdev_ops = {
-	.xmit	= mtk_tag_xmit,
-	.rcv	= mtk_tag_rcv,
+	.xmit		= mtk_tag_xmit,
+	.rcv		= mtk_tag_rcv,
+	.hash_nh_off	= 4,
+	.hash_proto_off	= 2,
 };
-- 
2.11.0
