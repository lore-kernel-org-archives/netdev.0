From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH 1/1]  net: nps_enet: Fix PCS reset
Date: Tue, 12 Jul 2016 16:01:11 +0300
Message-ID: <1468328471-8014-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eladkan@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <netdev@vger.kernel.org>,
	Noam Camus <noamca@mellanox.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamca@mellanox.com>

During commit b54b8c2d6e3c
 ("net: ezchip: adapt driver to little endian architecture")
 adapting to little endian architecture,
 zeroing of controller was left out.

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 06f0317..9b7a3f5 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -285,6 +285,7 @@ static void nps_enet_hw_reset(struct net_device *ndev)
 	ge_rst_value |= NPS_ENET_ENABLE << RST_GMAC_0_SHIFT;
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst_value);
 	usleep_range(10, 20);
+	ge_rst_value = 0;
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_RST, ge_rst_value);
 
 	/* Tx fifo reset sequence */
-- 
1.7.1
