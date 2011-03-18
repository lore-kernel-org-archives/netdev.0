From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 4/6] be2net: remove redundant code in be_worker()
Date: Fri, 18 Mar 2011 18:51:00 +0530
Message-ID: <a7e6eeac-4841-4215-983f-cecebea1df31@exht1.ad.emulex.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-3-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-4-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9939 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756545Ab1CRNVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:21:39 -0400
In-Reply-To: <1300454462-1234-4-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6be06df..0efa639 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1863,6 +1863,9 @@ static void be_worker(struct work_struct *work)
 	struct be_rx_obj *rxo;
 	int i;
 
+	if (!adapter->ue_detected && !lancer_chip(adapter))
+		be_detect_dump_ue(adapter);
+
 	/* when interrupts are not yet enabled, just reap any pending
 	* mcc completions */
 	if (!netif_running(adapter->netdev)) {
@@ -1875,9 +1878,6 @@ static void be_worker(struct work_struct *work)
 			be_cq_notify(adapter, mcc_obj->cq.id, false, mcc_compl);
 		}
 
-		if (!adapter->ue_detected && !lancer_chip(adapter))
-			be_detect_dump_ue(adapter);
-
 		goto reschedule;
 	}
 
@@ -1895,8 +1895,6 @@ static void be_worker(struct work_struct *work)
 			be_post_rx_frags(rxo, GFP_KERNEL);
 		}
 	}
-	if (!adapter->ue_detected && !lancer_chip(adapter))
-		be_detect_dump_ue(adapter);
 
 reschedule:
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
-- 
1.6.5.2

