From: Antonio Murdaca <antoniomurdaca@gmail.com>
Subject: [PATCH] ethernet: micrel: use time_after_eq
Date: Tue,  2 Jun 2015 14:35:52 +0200
Message-ID: <1433248552-7994-1-git-send-email-antonio.murdaca@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, akpm@linux-foundation.org,
	Antonio Murdaca <antonio.murdaca@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33318 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184AbbFBMf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 08:35:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use the time_after_eq macro for jiffies comparison operation

Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 6f332eb..48d2aec 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6664,7 +6664,7 @@ static void mib_read_work(struct work_struct *work)
 				wake_up_interruptible(
 					&hw_priv->counter[i].counter);
 			}
-		} else if (jiffies >= hw_priv->counter[i].time) {
+		} else if (time_after_eq(jiffies, hw_priv->counter[i].time)) {
 			/* Only read MIB counters when the port is connected. */
 			if (media_connected == mib->state)
 				hw_priv->counter[i].read = 1;
-- 
2.4.2
