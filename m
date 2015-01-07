From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] sh_eth: Fix access to TRSCER register
Date: Wed,  7 Jan 2015 14:35:47 +0900
Message-ID: <1420608947-6861-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com, linux-sh@vger.kernel.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TRSCER register is configured differently by SoCs. TRSCER of R-Car is
RINT8 bit only valid, other bits are reserved bits.
This removes access to TRSCER register reserve bit.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c29ba80..59ee457 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1294,7 +1294,11 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	/* Frame recv control (enable multiple-packets per rx irq) */
 	sh_eth_write(ndev, RMCR_RNC, RMCR);
 
-	sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2, TRSCER);
+	if (mdp->cd->register_type == SH_ETH_REG_FAST_RCAR)
+		sh_eth_write(ndev, DESC_I_RINT8, TRSCER);
+	else
+		sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2,
+			     TRSCER);
 
 	if (mdp->cd->bculr)
 		sh_eth_write(ndev, 0x800, BCULR);	/* Burst sycle set */
-- 
2.1.3

