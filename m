From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH] net/smsc911x: Fix deferred probe for interrupt
Date: Fri, 28 Aug 2015 11:50:15 -0700
Message-ID: <1440787815-24655-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pmta2.delivery5.ore.mailhop.org ([54.186.218.12]:25000 "EHLO
	pmta2.delivery5.ore.mailhop.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751725AbbH1SuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 14:50:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt handler may not be available when smsc911x probes if the
interrupt handler is a GPIO controller for example. Let's fix that
by adding handling for -EPROBE_DEFER.

Cc: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 959aeea..cb9f166f 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2435,7 +2435,10 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	res_size = resource_size(res);
 
 	irq = platform_get_irq(pdev, 0);
-	if (irq <= 0) {
+	if (irq == -EPROBE_DEFER) {
+		retval = -EPROBE_DEFER;
+		goto out_0;
+	} else if (irq <= 0) {
 		pr_warn("Could not allocate irq resource\n");
 		retval = -ENODEV;
 		goto out_0;
-- 
2.1.4
