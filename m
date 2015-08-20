From: Noam Camus <noamc@ezchip.com>
Subject: [v2 5/5] NET: nps_enet: minor namespace cleanup
Date: Thu, 20 Aug 2015 08:00:05 +0300
Message-ID: <1440046805-24459-6-git-send-email-noamc@ezchip.com>
References: <20150817.103607.1737876155019074073.davem@davemloft.net>
 <1440046805-24459-1-git-send-email-noamc@ezchip.com>
 <1440046805-24459-2-git-send-email-noamc@ezchip.com>
 <1440046805-24459-3-git-send-email-noamc@ezchip.com>
 <1440046805-24459-4-git-send-email-noamc@ezchip.com>
 <1440046805-24459-5-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440046805-24459-5-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

We define buf_int_enable in the minimal namespace it is used.
Signed-off-by: Noam Camus <noamc@ezchip.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 69b9129..63c2bcf 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -179,15 +179,16 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_buf_int_enable buf_int_enable;
 	u32 work_done;
 
-	buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
-	buf_int_enable.tx_done = NPS_ENET_ENABLE;
 	nps_enet_tx_handler(ndev);
 	work_done = nps_enet_rx_handler(ndev);
 	if (work_done < budget) {
+		struct nps_enet_buf_int_enable buf_int_enable;
+
 		napi_complete(napi);
+		buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
+		buf_int_enable.tx_done = NPS_ENET_ENABLE;
 		nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
 				 buf_int_enable.value);
 	}
-- 
1.7.1
