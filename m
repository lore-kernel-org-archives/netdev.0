From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] smsc911x: register irq with device name, not driver name
Date: Sat, 10 Jan 2009 13:29:29 +0000
Message-ID: <1231594169-24988-2-git-send-email-steve.glendinning@smsc.com>
References: <1231594169-24988-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60417 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751802AbZAJN24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 08:28:56 -0500
In-Reply-To: <1231594169-24988-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change lets "cat /proc/interrupts" show the name of the ethernet
device (e.g. eth0) rather than the driver name (smsc911x).

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 1f443d8..ad47899 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1968,7 +1968,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
 
 	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
-			     SMSC_CHIPNAME, dev);
+			     dev->name, dev);
 	if (retval) {
 		SMSC_WARNING(PROBE,
 			"Unable to claim requested irq: %d", dev->irq);
-- 
1.6.0.6

