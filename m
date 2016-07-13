From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH 1/2] net: nps_enet: fix coding style issues
Date: Wed, 13 Jul 2016 16:58:06 +0300
Message-ID: <1468418287-26512-2-git-send-email-eladkan@mellanox.com>
References: <1468418287-26512-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eladkan@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <netdev@vger.kernel.org>,
	<noamca@mellanox.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468418287-26512-1-git-send-email-eladkan@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>

Fix following coding style problems :

ERROR: else should follow close brace '}'
+	}
+	else { /* !dst_is_aligned */

WARNING: Missing a blank line after declarations
+			u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+			put_unaligned_be32(buf, reg);

WARNING: Missing a blank line after declarations
+		u32 buf;
+		ioread32_rep(priv->regs_base + NPS_ENET_REG_RX_BUF, &buf, 1);

CHECK: Blank lines aren't necessary before a close brace '}'
+
+	}

total: 1 errors, 2 warnings, 1 checks, 683 lines checked

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 06f0317..b182e2a 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -46,16 +46,17 @@ static void nps_enet_read_rx_fifo(struct net_device *ndev,
 	if (dst_is_aligned) {
 		ioread32_rep(priv->regs_base + NPS_ENET_REG_RX_BUF, reg, len);
 		reg += len;
-	}
-	else { /* !dst_is_aligned */
+	} else { /* !dst_is_aligned */
 		for (i = 0; i < len; i++, reg++) {
 			u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
+
 			put_unaligned_be32(buf, reg);
 		}
 	}
 	/* copy last bytes (if any) */
 	if (last) {
 		u32 buf;
+
 		ioread32_rep(priv->regs_base + NPS_ENET_REG_RX_BUF, &buf, 1);
 		memcpy((u8 *)reg, &buf, last);
 	}
@@ -459,7 +460,6 @@ static void nps_enet_set_rx_mode(struct net_device *ndev)
 			 | NPS_ENET_ENABLE << CFG_2_DISK_DA_SHIFT;
 		ge_mac_cfg_2_value = (ge_mac_cfg_2_value & ~CFG_2_DISK_MC_MASK)
 			 | NPS_ENET_ENABLE << CFG_2_DISK_MC_SHIFT;
-
 	}
 
 	nps_enet_reg_set(priv, NPS_ENET_REG_GE_MAC_CFG_2, ge_mac_cfg_2_value);
-- 
1.7.1
