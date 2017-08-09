From: John Crispin <john@phrozen.org>
Subject: [PATCH 3/4] net-next: tag_mtk: add flow_dissect callback to the ops struct
Date: Wed,  9 Aug 2017 14:41:18 +0200
Message-ID: <20170809124119.24320-4-john@phrozen.org>
References: <20170809124119.24320-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809124119.24320-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MT7530 inserts the 4 magic header in between the 802.3 address and
protocol field. The patch implements the callback that can be called by
the flow dissector to figure out the real protocol and offset of the
network header. With this patch applied we can properly parse the packet
and thus make hashing function properly.

Signed-off-by: Muciri Gatimu <muciri@openmesh.com>
Signed-off-by: Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>
Signed-off-by: John Crispin <john@phrozen.org>
---
 net/dsa/tag_mtk.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 2f32b7ea3365..02163c045a96 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -87,7 +87,17 @@ static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	return skb;
 }
 
+static int mtk_tag_flow_dissect(const struct sk_buff *skb, __be16 *proto,
+				int *offset)
+{
+	*offset = 4;
+	*proto = ((__be16 *)skb->data)[1];
+
+	return 0;
+}
+
 const struct dsa_device_ops mtk_netdev_ops = {
-	.xmit	= mtk_tag_xmit,
-	.rcv	= mtk_tag_rcv,
+	.xmit		= mtk_tag_xmit,
+	.rcv		= mtk_tag_rcv,
+	.flow_dissect	= mtk_tag_flow_dissect,
 };
-- 
2.11.0
