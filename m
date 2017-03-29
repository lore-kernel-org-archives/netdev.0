From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 3/5] net-next: ethernet: mediatek: add CDM able to recognize the tag for DSA
Date: Wed, 29 Mar 2017 17:38:21 +0800
Message-ID: <1490780303-18598-4-git-send-email-sean.wang@mediatek.com>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <davem@davemloft.net>,
        <sean.wang@mediatek.com>, <Landen.Chao@mediatek.com>,
        <keyhaede@gmail.com>, <objelf@gmail.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <matthias.bgg@gmail.com>,
        <robh+dt@kernel.org>, <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

The patch adds the setup for allowing CDM can recognize these packets with
carrying port-distinguishing tag. Otherwise, these tagging packets will be
handled incorrectly by CDM. The setup is also working out for general
untag packets as well.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
Signed-off-by: Landen Chao <Landen.Chao@mediatek.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 6 ++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 9e75768..c21ed99 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1846,6 +1846,12 @@ static int mtk_hw_init(struct mtk_eth *eth)
 	/* GE2, Force 1000M/FD, FC ON */
 	mtk_w32(eth, MAC_MCR_FIXED_LINK, MTK_MAC_MCR(1));
 
+	/* Indicates CDM to parse the MTK special tag from CPU
+	 * which also is working out for untag packets.
+	 */
+	val = mtk_r32(eth, MTK_CDMQ_IG_CTRL);
+	mtk_w32(eth, val | MTK_CDMQ_STAG_EN, MTK_CDMQ_IG_CTRL);
+
 	/* Enable RX VLan Offloading */
 	mtk_w32(eth, 1, MTK_CDMP_EG_CTRL);
 
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 99b1c8e..996024d 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -70,6 +70,10 @@
 /* Frame Engine Interrupt Grouping Register */
 #define MTK_FE_INT_GRP		0x20
 
+/* CDMP Ingress Control Register */
+#define MTK_CDMQ_IG_CTRL	0x1400
+#define MTK_CDMQ_STAG_EN	BIT(0)
+
 /* CDMP Exgress Control Register */
 #define MTK_CDMP_EG_CTRL	0x404
 
-- 
1.9.1
