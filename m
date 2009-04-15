From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 12/12] fec: call fec_restart() in fec_open()
Date: Wed, 15 Apr 2009 13:32:25 +0200
Message-ID: <1239795145-27558-13-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-11-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-12-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49322 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758894AbZDOLgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:36:24 -0400
In-Reply-To: <1239795145-27558-12-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We called fec_stop() in fec_enet_close(), thus we have to call
fec_restart() in fec_enet_open().

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 0e1d268..28db691 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1490,6 +1490,8 @@ fec_enet_open(struct net_device *dev)
 	fep->sequence_done = 0;
 	fep->link = 0;
 
+	fec_restart(dev, 1);
+
 	if (fep->phy) {
 		mii_do_cmd(dev, fep->phy->ack_int);
 		mii_do_cmd(dev, fep->phy->config);
@@ -1506,18 +1508,14 @@ fec_enet_open(struct net_device *dev)
 			schedule();
 
 		mii_do_cmd(dev, fep->phy->startup);
-
-		/* Set the initial link state to true. A lot of hardware
-		 * based on this device does not implement a PHY interrupt,
-		 * so we are never notified of link change.
-		 */
-		fep->link = 1;
-	} else {
-		fep->link = 1; /* lets just try it and see */
-		/* no phy,  go full duplex,  it's most likely a hub chip */
-		fec_restart(dev, 1);
 	}
 
+	/* Set the initial link state to true. A lot of hardware
+	 * based on this device does not implement a PHY interrupt,
+	 * so we are never notified of link change.
+	 */
+	fep->link = 1;
+
 	netif_start_queue(dev);
 	fep->opened = 1;
 	return 0;
-- 
1.6.2.1

