From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH net-master v2] net: fec: fix initial runtime PM refcount
Date: Wed,  5 Aug 2015 10:49:24 +0200
Message-ID: <1438764564-15321-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	kernel@pengutronix.de, Lucas Stach <l.stach@pengutronix.de>,
	Alan Stern <stern@rowland.harvard.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35400 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbbHEItd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 04:49:33 -0400
In-Reply-To: <1438617011-19073-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Lucas Stach <l.stach@pengutronix.de>

The clocks are initially active and thus the device is marked active.
This still keeps the PM refcount at 0, the pm_runtime_put_autosuspend()
call at the end of probe then leaves us with an invalid refcount of -1,
which in turn leads to the device staying in suspended state even thoug=
h
netdev open had been called.

=46ix this by initializing the refcount to be coherent with the initial
device status.

=46ixes: 8fff755e9f8 (net: fec: Ensure clocks are enabled while using m=
dio bus)
Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
Acked-by: Alan Stern <stern@rowland.harvard.edu>
Tested-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello David,

I think this is fine to apply now for 4.2-rc. I just picked up the
patch, added Alan's ack and a tested-by for me to make it easier for
you.

Best regards
Uwe

 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 32e3807c650e..271bb5862346 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3433,6 +3433,7 @@ fec_probe(struct platform_device *pdev)
=20
 	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
 	pm_runtime_use_autosuspend(&pdev->dev);
+	pm_runtime_get_noresume(&pdev->dev);
 	pm_runtime_set_active(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
=20
--=20
2.4.6
