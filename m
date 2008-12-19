From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] smsc911x: don't clobber driver_data
Date: Fri, 19 Dec 2008 18:05:29 +0000
Message-ID: <1229709930-19925-1-git-send-email-steve.glendinning@smsc.com>
Cc: dfoley@telus.net, Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:40774 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751758AbYLSSFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 13:05:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc911x uses driver_data to store our net_device, don't overwrite this
with the mii_bus.

Reported and fixed by dfoley@telus.net.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index fa28542..cd925de 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -822,7 +822,6 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 		pdata->mii_bus->irq[i] = PHY_POLL;
 
 	pdata->mii_bus->parent = &pdev->dev;
-	dev_set_drvdata(&pdev->dev, &pdata->mii_bus);
 
 	pdata->using_extphy = 0;
 
-- 
1.6.0.4

