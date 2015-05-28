From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net 2/3] bna: remove unreasonable iocpf timer start
Date: Thu, 28 May 2015 23:10:07 +0200
Message-ID: <1432847408-5066-3-git-send-email-ivecera@redhat.com>
References: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461AbbE1VKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 17:10:06 -0400
In-Reply-To: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver starts iocpf timer prior bnad_ioceth_enable() call and this is
unreasonable. This piece of code probably originates from Brocade/Qlogic
out-of-box driver during initial import into upstream. This driver uses
only one timer and queue to implement multiple timers and this timer is
started at this place. The upstream driver uses multiple timers instead
of this.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 37072a8..caae6cb 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3701,10 +3701,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	setup_timer(&bnad->bna.ioceth.ioc.sem_timer, bnad_iocpf_sem_timeout,
 				((unsigned long)bnad));
 
-	/* Now start the timer before calling IOC */
-	mod_timer(&bnad->bna.ioceth.ioc.iocpf_timer,
-		  jiffies + msecs_to_jiffies(BNA_IOC_TIMER_FREQ));
-
 	/*
 	 * Start the chip
 	 * If the call back comes with error, we bail out.
-- 
2.3.6
