From: "Stanley.Miao" <stanley.miao@windriver.com>
Subject: [PATCH] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 13:21:52 +0800
Message-ID: <1231910512-8420-1-git-send-email-stanley.miao@windriver.com>
Cc: steve.glendinning@smsc.com, linux-arm-kernel@lists.arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47420 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894AbZANFNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 00:13:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calling request IRQ it is desirable to allow platforms
to specific flags for the call to request_irq. Adding irq_flags
to smsc911x_platform_config allows these flags to be passed.

Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
---
 drivers/net/smsc911x.c   |    6 ++++--
 include/linux/smsc911x.h |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index f513bdf..1092517 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1896,6 +1896,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	unsigned int intcfg = 0;
 	int res_size;
 	int retval;
+	irq_flags;
 	DECLARE_MAC_BUF(mac);
 
 	pr_info("%s: Driver version %s.\n", SMSC_CHIPNAME, SMSC_DRV_VERSION);
@@ -1968,8 +1969,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	smsc911x_reg_write(pdata, INT_EN, 0);
 	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
 
-	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
-			     dev->name, dev);
+	irq_flags = IRQF_DISABLED | pdata->config.irq_flags;
+	retval = request_irq(dev->irq, smsc911x_irqhandler, irq_flags,
+				dev->name, dev);
 	if (retval) {
 		SMSC_WARNING(PROBE,
 			"Unable to claim requested irq: %d", dev->irq);
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 1cbf031..0330f57 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -28,6 +28,7 @@
 struct smsc911x_platform_config {
 	unsigned int irq_polarity;
 	unsigned int irq_type;
+	unsigned int irq_flags;
 	unsigned int flags;
 	phy_interface_t phy_interface;
 };
-- 
1.5.6.3

