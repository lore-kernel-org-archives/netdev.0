From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/4] bnx2x: use smp_mb() to keep ordering of read write operations
Date: Tue,  9 Mar 2010 17:55:00 +0100
Message-ID: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923Ab0CIQ4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 11:56:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we want to keep ordering of write to fp->bd_tx_cons and
netif_tx_queue_stopped(txq), what is read of txq->state, we have to use
general memory barrier.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ed785a3..9fc0f6a 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -963,7 +963,7 @@ static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	 * start_xmit() will miss it and cause the queue to be stopped
 	 * forever.
 	 */
-	smp_wmb();
+	smp_mb();
 
 	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
-- 
1.6.2.5

