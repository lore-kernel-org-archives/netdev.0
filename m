From: David Fries <david@fries.net>
Subject: [PATCH 2/2] ne.c Fix suspend and resume for ISA PnP cards.
Date: Sat, 13 Sep 2008 11:54:01 -0500
Message-ID: <20080913165401.GI28469@spacedout.fries.net>
References: <20080913144457.GE28469@spacedout.fries.net> <20080914.001300.15242170.anemo@mba.ocn.ne.jp> <20080913151906.GG28469@spacedout.fries.net> <20080914.002906.48532607.anemo@mba.ocn.ne.jp> <20080913164736.GH28469@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.gortmaker@gmail.com, akpm@linux-foundation.org,
	p_gortmaker@yahoo.com, alan@lxorguk.ukuu.org.uk, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:60347 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbYIMQy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2008 12:54:57 -0400
Content-Disposition: inline
In-Reply-To: <20080913164736.GH28469@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Fries <david@fries.net>

A call to pnp_stop_dev and pnp_start_dev now shuts down and
initializes plug and play devices for suspend and resume.

Signed-off-by: David Fries <david@fries.net>
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>
---
This version is the same as the last PATCH 2/2, only with updated line
offsets.

 drivers/net/ne.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 4cb9c11..f9da162 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -895,8 +895,12 @@ static int ne_drv_suspend(struct platform_device *pdev, pm_message_t state)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
 		netif_device_detach(dev);
+		if (idev)
+			pnp_stop_dev(idev);
+	}
 	return 0;
 }
 
@@ -905,6 +909,9 @@ static int ne_drv_resume(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+		if (idev)
+			pnp_start_dev(idev);
 		ne_reset_8390(dev);
 		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
-- 
1.4.4.4

