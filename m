From: Gerard Lledo <gerard.lledo@gmail.com>
Subject: [PATCH] sungem: Fix WakeOnLan
Date: Sat, 28 Apr 2012 21:52:37 +0300
Message-ID: <1335639157-6336-1-git-send-email-gerard.lledo@gmail.com>
Cc: davem@davemloft.net, Gerard Lledo <gerard.lledo@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41853 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab2D1SxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 14:53:13 -0400
Received: by lbbgf7 with SMTP id gf7so1186727lbb.19
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 11:53:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Lledo <gerard.lledo@gmail.com>

WakeOnLan was broken in this driver because gp->asleep_wol is a 1-bit
bitfield and it was being assigned WAKE_MAGIC, which is (1 << 5).
gp->asleep_wol remains 0 and the machine never wakes up.  Fixed by casting
gp->wake_on_lan to bool.  Tested on an iBook G4.

Signed-off-by: Gerard Lledo <gerard.lledo@gmail.com>
---
 drivers/net/ethernet/sun/sungem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 558409f..4ba9690 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2339,7 +2339,7 @@ static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(dev);
 
 	/* Switch off chip, remember WOL setting */
-	gp->asleep_wol = gp->wake_on_lan;
+	gp->asleep_wol = !!gp->wake_on_lan;
 	gem_do_stop(dev, gp->asleep_wol);
 
 	/* Unlock the network stack */
-- 
1.7.10
