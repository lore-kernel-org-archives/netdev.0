From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 48/64] drivers: net: amd: use setup_timer() helper.
Date: Thu, 21 Sep 2017 22:35:09 +0530
Message-ID: <1506013525-29291-49-git-send-email-allen.lkml@gmail.com>
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
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36832 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752938AbdIURKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:10:47 -0400
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/amd/a2065.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index e22f976..998d30e 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -733,10 +733,9 @@ static int a2065_init_one(struct zorro_dev *z,
 	dev->watchdog_timeo = 5*HZ;
 	dev->dma = 0;
 
-	init_timer(&priv->multicast_timer);
-	priv->multicast_timer.data = (unsigned long) dev;
-	priv->multicast_timer.function =
-		(void (*)(unsigned long))lance_set_multicast;
+	setup_timer(&priv->multicast_timer,
+		    (void(*)(unsigned long))lance_set_multicast,
+		    (unsigned long)dev);
 
 	err = register_netdev(dev);
 	if (err) {
-- 
2.7.4
