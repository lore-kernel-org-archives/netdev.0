From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] sky2: Shut off interrupts before NAPI
Date: Thu, 13 May 2010 09:12:50 -0700
Message-ID: <20100513161351.171864218@vyatta.com>
References: <20100513161247.833356588@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39380 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757360Ab0EMXaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 19:30:25 -0400
Content-Disposition: inline; filename=sky2-mike3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Interrupts should be masked, then synchronized, and
finally NAPI should be disabled.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
Not a regression, only apply to -next


--- a/drivers/net/sky2.c	2010-05-13 08:57:31.127627401 -0700
+++ b/drivers/net/sky2.c	2010-05-13 08:57:32.736962641 -0700
@@ -3320,10 +3320,10 @@ static void sky2_restart(struct work_str
 
 	rtnl_lock();
 
-	napi_disable(&hw->napi);
-	synchronize_irq(hw->pdev->irq);
 	imask = sky2_read32(hw, B0_IMSK);
 	sky2_write32(hw, B0_IMSK, 0);
+	synchronize_irq(hw->pdev->irq);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];


