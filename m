From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH] DM9000 - minor code cleanups
Date: Wed, 14 Jun 2006 00:09:17 +0100
Message-ID: <20060613230917.GA27085@home.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-84-9-203-241.bulldogdsl.com ([84.9.203.241]:5294 "EHLO
	aeryn.fluff.org.uk") by vger.kernel.org with ESMTP id S964788AbWFMXJS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 19:09:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Ensure the driver's module owner field is
initialised for when this is being built and
loaded as a module.

Also change make the dm9000_tx_done function
static, as it is not exported elsewhere.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dm9k-minor-cleanups.patch"

--- ../linux-2.6.17/linux-2.6.17-rc5/drivers/net/dm9000.c	2006-03-20 05:53:29.000000000 +0000
+++ linux-2.6.16-simtec2/drivers/net/dm9000.c	2006-05-22 21:46:18.000000000 +0100
@@ -767,7 +768,7 @@ dm9000_stop(struct net_device *ndev)
  * receive the packet to upper layer, free the transmitted packet
  */
 
-void
+static void
 dm9000_tx_done(struct net_device *dev, board_info_t * db)
 {
 	int tx_status = ior(db, DM9000_NSR);	/* Got TX status */
@@ -1187,13 +1188,14 @@ dm9000_drv_remove(struct platform_device
 }
 
 static struct platform_driver dm9000_driver = {
+	.driver	= {
+		.name    = "dm9000",
+		.owner	 = THIS_MODULE,
+	},
 	.probe   = dm9000_probe,
 	.remove  = dm9000_drv_remove,
 	.suspend = dm9000_drv_suspend,
 	.resume  = dm9000_drv_resume,
-	.driver	= {
-		.name	= "dm9000",
-	},
 };
 
 static int __init

--x+6KMIRAuhnl3hBn--
