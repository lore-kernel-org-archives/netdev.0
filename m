From: John Crispin <john@phrozen.org>
Subject: [PATCH V3 4/4] net-next: mediatek: properly handle RGMII modes
Date: Tue, 10 May 2016 07:08:41 +0200
Message-ID: <1462856921-27441-5-git-send-email-john@phrozen.org>
References: <1462856921-27441-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462856921-27441-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If an external Gigabit PHY is connected to either of the MACs we need to
be able to tell the PHY to use a delay. Not doing so will result in heavy
packet loss and/or data corruption when using PHYs such as the IC+ IP1001.
We tell the PHY which MII delay mode to use via the devictree.

The ethernet driver needs to be adapted to handle all 3 rgmii-*id modes
in the same way as normal rgmii when setting up the MAC.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4d59bda..c5ddb4d 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -226,6 +226,9 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 		return -ENODEV;
 
 	switch (of_get_phy_mode(np)) {
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII:
 		ge_mode = 0;
 		break;
-- 
1.7.10.4
