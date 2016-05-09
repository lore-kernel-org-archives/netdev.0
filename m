From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 04/22] net-next: mediatek: properly handle RGMII modes
Date: Mon,  9 May 2016 12:03:56 +0200
Message-ID: <1462788254-40572-5-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47270 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbcEIKEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:30 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an external Gigabit PHY is connected to either of the MACs we need to
be able to tell the PHY to use a delay. Not doing so will result in heavy
packet loss and/or data corruption when using PHYs such as the IC+ IP1001.
We tell the PHY which MII delay mode to use via the devictree.

The ethernet driver needs to be adapted to handle all 3 rgmii-*id modes
in the same way as normal rgmii when setting up the MAC.

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
