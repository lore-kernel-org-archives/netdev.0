From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 06/64] drivers: net: bcm63xx: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:27 +0530
Message-ID: <1506013525-29291-7-git-send-email-allen.lkml@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36819 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751787AbdIURGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:06:20 -0400
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 4f3845a..f8bbbbf 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1857,9 +1857,8 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->rx_lock);
 
 	/* init rx timeout (used for oom) */
-	init_timer(&priv->rx_timeout);
-	priv->rx_timeout.function = bcm_enet_refill_rx_timer;
-	priv->rx_timeout.data = (unsigned long)dev;
+	setup_timer(&priv->rx_timeout, bcm_enet_refill_rx_timer,
+		    (unsigned long)dev);
 
 	/* init the mib update lock&work */
 	mutex_init(&priv->mib_update_lock);
-- 
2.7.4
