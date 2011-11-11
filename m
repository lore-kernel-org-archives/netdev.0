From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/4] be2net: stop checking the UE registers after an EEH error
Date: Fri, 11 Nov 2011 10:47:58 +0530
Message-ID: <1320988680-7842-3-git-send-email-sathya.perla@emulex.com>
References: <1320988680-7842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:4695 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751387Ab1KKFUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 00:20:34 -0500
In-Reply-To: <1320988680-7842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 83d971d..99da07f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1978,6 +1978,9 @@ void be_detect_dump_ue(struct be_adapter *adapter)
 	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
 
+	if (adapter->eeh_err || adapter->ue_detected)
+		return;
+
 	if (lancer_chip(adapter)) {
 		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
 		if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
@@ -2039,8 +2042,7 @@ static void be_worker(struct work_struct *work)
 	struct be_rx_obj *rxo;
 	int i;
 
-	if (!adapter->ue_detected)
-		be_detect_dump_ue(adapter);
+	be_detect_dump_ue(adapter);
 
 	/* when interrupts are not yet enabled, just reap any pending
 	* mcc completions */
-- 
1.7.4
