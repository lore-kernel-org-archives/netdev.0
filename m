From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl1: use spin_trylock_irqsave()
Date: Tue, 31 Jul 2007 19:07:02 -0500
Message-ID: <11859268222715-git-send-email-jacliburn@bellsouth.net>
Cc: mingo@elte.hu, csnook@redhat.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nando@ccrma.Stanford.EDU, tglx@linutronix.de, brbrofsvl@gmail.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf23aec.mail.bellsouth.net ([205.152.59.71]:49296 "EHLO
	imf23aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751558AbXHAAHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 20:07:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>

use the simpler spin_trylock_irqsave() API to get the adapter lock.

[ this is also a fix for -rt where adapter->lock is a sleeping lock. ]

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 56f6389..3c1984e 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1704,10 +1704,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	local_irq_save(flags);
-	if (!spin_trylock(&adapter->lock)) {
+	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
 		/* Can't get lock - tell upper layer to requeue */
-		local_irq_restore(flags);
 		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
-- 
1.5.2.2

