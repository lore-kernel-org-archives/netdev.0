From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 08/64] drivers: net: am79c961: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:34:29 +0530
Message-ID: <1506013525-29291-9-git-send-email-allen.lkml@gmail.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38181 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751787AbdIURGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:06:33 -0400
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/amd/am79c961a.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index b11e910..0612dbe 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -728,9 +728,7 @@ static int am79c961_probe(struct platform_device *pdev)
 	am79c961_banner();
 
 	spin_lock_init(&priv->chip_lock);
-	init_timer(&priv->timer);
-	priv->timer.data = (unsigned long)dev;
-	priv->timer.function = am79c961_timer;
+	setup_timer(&priv->timer, am79c961_timer, (unsigned long)dev);
 
 	if (am79c961_hw_init(dev))
 		goto release;
-- 
2.7.4
