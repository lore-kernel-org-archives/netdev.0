From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] PHY: add BCM5464 support to broadcom PHY driver
Date: Mon, 14 Apr 2008 23:35:41 -0400
Message-ID: <20080415033538.GA14095@windriver.com>
References: <1207752406-4624-1-git-send-email-paul.gortmaker@windriver.com> <20080409150412.GA4912@windriver.com> <48007C3F.5050505@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [128.224.252.2] ([128.224.252.2]:14953 "EHLO
	yow-pgortmak-d1.corp.ad.wrs.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761922AbYDODfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 23:35:14 -0400
Content-Disposition: inline
In-Reply-To: <48007C3F.5050505@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message: Re: [PATCH] PHY: add BCM5464 support to broadcom PHY driver
on 12/04/2008 Jeff Garzik wrote:

> doesn't seem to apply...  can you please regenerate against  
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.26.git ?

No problem.  The already queued BCM 5481 and this overlapped. It should
be good to go now.

P.
---

 From f01cb20f9d5c4f6cc9040c0a5ec13409396e64d5 Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 14 Apr 2008 23:27:12 -0400
Subject: [PATCH] PHY: add BCM5464 support to broadcom PHY driver

The BCM5464 can be used with the current broadcom PHY driver
by just adding the appropriate chip ID and using the existing
support within.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/phy/broadcom.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f5310ed..60c5cfe 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -176,6 +176,20 @@ static struct phy_driver bcm5461_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5464_driver = {
+	.phy_id		= 0x002060b0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5464",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE },
+};
+
 static struct phy_driver bcm5481_driver = {
 	.phy_id		= 0x0143bca0,
 	.phy_id_mask	= 0xfffffff0,
@@ -217,6 +231,9 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5461_driver);
 	if (ret)
 		goto out_5461;
+	ret = phy_driver_register(&bcm5464_driver);
+	if (ret)
+		goto out_5464;
 	ret = phy_driver_register(&bcm5481_driver);
 	if (ret)
 		goto out_5481;
@@ -228,6 +245,8 @@ static int __init broadcom_init(void)
 out_5482:
 	phy_driver_unregister(&bcm5481_driver);
 out_5481:
+	phy_driver_unregister(&bcm5464_driver);
+out_5464:
 	phy_driver_unregister(&bcm5461_driver);
 out_5461:
 	phy_driver_unregister(&bcm5421_driver);
@@ -241,6 +260,7 @@ static void __exit broadcom_exit(void)
 {
 	phy_driver_unregister(&bcm5482_driver);
 	phy_driver_unregister(&bcm5481_driver);
+	phy_driver_unregister(&bcm5464_driver);
 	phy_driver_unregister(&bcm5461_driver);
 	phy_driver_unregister(&bcm5421_driver);
 	phy_driver_unregister(&bcm5411_driver);
-- 
1.5.4.3

