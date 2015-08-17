From: Noam Camus <noamc@ezchip.com>
Subject: [v1 4/6] NET: nps_enet: drop control frames
Date: Mon, 17 Aug 2015 08:58:37 +0300
Message-ID: <1439791119-26892-5-git-send-email-noamc@ezchip.com>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
 <1439791119-26892-2-git-send-email-noamc@ezchip.com>
 <1439791119-26892-3-git-send-email-noamc@ezchip.com>
 <1439791119-26892-4-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439791119-26892-4-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

We set controller to drop control frames and not trying
to pass them on. This is only needed for debug reasons.

Signed-off-by: Noam Camus <noamc@ezchip.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index f78ad3d..0c13015 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -307,11 +307,8 @@ static void nps_enet_hw_enable_control(struct net_device *ndev)
 
 	/* Discard Packets bigger than max frame length */
 	max_frame_length = ETH_HLEN + ndev->mtu + ETH_FCS_LEN;
-	if (max_frame_length <= NPS_ENET_MAX_FRAME_LENGTH) {
+	if (max_frame_length <= NPS_ENET_MAX_FRAME_LENGTH)
 		ge_mac_cfg_3->max_len = max_frame_length;
-		nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_3,
-				 ge_mac_cfg_3->value);
-	}
 
 	/* Enable interrupts */
 	buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
@@ -339,11 +336,14 @@ static void nps_enet_hw_enable_control(struct net_device *ndev)
 	ge_mac_cfg_0.tx_fc_en = NPS_ENET_ENABLE;
 	ge_mac_cfg_0.rx_fc_en = NPS_ENET_ENABLE;
 	ge_mac_cfg_0.tx_fc_retr = NPS_ENET_GE_MAC_CFG_0_TX_FC_RETR;
+	ge_mac_cfg_3->cf_drop = NPS_ENET_ENABLE;
 
 	/* Enable Rx and Tx */
 	ge_mac_cfg_0.rx_en = NPS_ENET_ENABLE;
 	ge_mac_cfg_0.tx_en = NPS_ENET_ENABLE;
 
+	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_3,
+			 ge_mac_cfg_3->value);
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_0,
 			 ge_mac_cfg_0.value);
 }
-- 
1.7.1
