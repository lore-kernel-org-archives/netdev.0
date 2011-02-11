From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 08/14] net/fec: add phy_stop to fec_enet_close
Date: Fri, 11 Feb 2011 11:32:16 +0100
Message-ID: <1297420342-17739-8-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52456 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab1BKKca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:30 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This undoes the effects of phy_start in fec_enet_open.

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index dd4e580..d3dbff5 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1029,8 +1029,10 @@ fec_enet_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	fec_stop(dev);
=20
-	if (fep->phy_dev)
+	if (fep->phy_dev) {
+		phy_stop(fep->phy_dev);
 		phy_disconnect(fep->phy_dev);
+	}
=20
         fec_enet_free_buffers(dev);
=20
--=20
1.7.2.3

