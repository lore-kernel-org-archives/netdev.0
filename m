From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 3/5] sky2: Shut off interrupts before NAPI
Date: Thu, 13 May 2010 08:29:11 +0900
Message-ID: <4BEB39C7.5010409@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:49578 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab0ELXiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 19:38:14 -0400
Received: by pzk42 with SMTP id 42so348908pzk.4
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 16:38:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupts should be masked, then synchronized, and
finally NAPI should be disabled.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 58ae840..04adcee 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3266,10 +3266,10 @@ static void sky2_restart(struct work_struct *work)
 
 	rtnl_lock();
 
-	napi_disable(&hw->napi);
-	synchronize_irq(hw->pdev->irq);
 	imask = sky2_read32(hw, B0_IMSK);
 	sky2_write32(hw, B0_IMSK, 0);
+	synchronize_irq(hw->pdev->irq);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
-- 
1.5.6.5


