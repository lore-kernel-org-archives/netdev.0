From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 02/10] smsc911x: register isr as IRQF_SHARED
Date: Tue, 27 Jan 2009 16:51:10 +0000
Message-ID: <1233075077-17205-3-git-send-email-steve.glendinning@smsc.com>
References: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-2-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:53200 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755760AbZA0QvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:51:15 -0500
In-Reply-To: <1233075077-17205-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The isr supports shared operation, so register it with the IRQF_SHARED
flag to indicate this.

This patch also removes the IRQF_DISABLED flag.  This driver doesn't
need it, and IRQF_DISABLED isn't guaranteed when using shared interrupts.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 3565df1..f882fd5 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1978,7 +1978,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
 
 	retval = request_irq(dev->irq, smsc911x_irqhandler,
-			     irq_flags | IRQF_DISABLED, dev->name, dev);
+			     irq_flags | IRQF_SHARED, dev->name, dev);
 	if (retval) {
 		SMSC_WARNING(PROBE,
 			"Unable to claim requested irq: %d", dev->irq);
-- 
1.6.0.6

