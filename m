From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 57/64] drivers: net: stmmac: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:18 +0530
Message-ID: <1506013525-29291-58-git-send-email-allen.lkml@gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, m.grzeschik@pengutronix.de,
        dmitry.tarnyagin@lockless.no, wg@grandegger.com,
        mkl@pengutronix.de, mark.einon@gmail.com, linux@armlinux.org.uk,
        pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        davem@davemloft.net, linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1763e48..f41661a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2217,10 +2217,8 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 {
 	priv->tx_coal_frames = STMMAC_TX_FRAMES;
 	priv->tx_coal_timer = STMMAC_COAL_TX_TIMER;
-	init_timer(&priv->txtimer);
+	setup_timer(&priv->txtimer, stmmac_tx_timer, (unsigned long)priv);
 	priv->txtimer.expires = STMMAC_COAL_TIMER(priv->tx_coal_timer);
-	priv->txtimer.data = (unsigned long)priv;
-	priv->txtimer.function = stmmac_tx_timer;
 	add_timer(&priv->txtimer);
 }
 
-- 
2.7.4
