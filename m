From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 14/15] be2net: detect a UE even when a interface
 is down.
Date: Fri, 11 Feb 2011 17:38:29 -0600
Message-ID: <20110211233829.GA18507@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51251 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758107Ab1BKXiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:38:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1f5e342..aad7ea3 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1866,6 +1866,10 @@ static void be_worker(struct work_struct *work)
 			struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 			be_cq_notify(adapter, mcc_obj->cq.id, false, mcc_compl);
 		}
+
+		if (!adapter->ue_detected && !lancer_chip(adapter))
+			be_detect_dump_ue(adapter);
+
 		goto reschedule;
 	}
 
-- 
1.7.1

