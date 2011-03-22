From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 3/5] be2net: remove redundant code in be_worker()
Date: Tue, 22 Mar 2011 12:19:27 +0530
Message-ID: <fa54f88f-5b2f-4c6e-8edd-36b641e8d7af@exht1.ad.emulex.com>
References: <1300776569-15586-1-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-2-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:5039 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754232Ab1CVGul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 02:50:41 -0400
In-Reply-To: <1300776569-15586-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6616300..3bf79d1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1868,6 +1868,9 @@ static void be_worker(struct work_struct *work)
 	struct be_rx_obj *rxo;
 	int i;
 
+	if (!adapter->ue_detected && !lancer_chip(adapter))
+		be_detect_dump_ue(adapter);
+
 	/* when interrupts are not yet enabled, just reap any pending
 	* mcc completions */
 	if (!netif_running(adapter->netdev)) {
@@ -1880,9 +1883,6 @@ static void be_worker(struct work_struct *work)
 			be_cq_notify(adapter, mcc_obj->cq.id, false, mcc_compl);
 		}
 
-		if (!adapter->ue_detected && !lancer_chip(adapter))
-			be_detect_dump_ue(adapter);
-
 		goto reschedule;
 	}
 
@@ -1900,8 +1900,6 @@ static void be_worker(struct work_struct *work)
 			be_post_rx_frags(rxo, GFP_KERNEL);
 		}
 	}
-	if (!adapter->ue_detected && !lancer_chip(adapter))
-		be_detect_dump_ue(adapter);
 
 reschedule:
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
-- 
1.6.5.2

