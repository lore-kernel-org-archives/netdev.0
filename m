From: Noam Camus <noamc@ezchip.com>
Subject: [v1 5/6] NET: nps_enet: TX done acknowledge.
Date: Mon, 17 Aug 2015 08:58:38 +0300
Message-ID: <1439791119-26892-6-git-send-email-noamc@ezchip.com>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
 <1439791119-26892-2-git-send-email-noamc@ezchip.com>
 <1439791119-26892-3-git-send-email-noamc@ezchip.com>
 <1439791119-26892-4-git-send-email-noamc@ezchip.com>
 <1439791119-26892-5-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439791119-26892-5-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

This is needed for when TX done interrupt is in
"level mode".
For example it is true for some simulators of this device.

Signed-off-by: Noam Camus <noamc@ezchip.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 0c13015..de4aafd 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -150,6 +150,9 @@ static void nps_enet_tx_handler(struct net_device *ndev)
 	if (!priv->tx_packet_sent || tx_ctrl.ct)
 		return;
 
+	/* Ack Tx ctrl register */
+	nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, 0);
+
 	/* Check Tx transmit error */
 	if (unlikely(tx_ctrl.et)) {
 		ndev->stats.tx_errors++;
-- 
1.7.1
