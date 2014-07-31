From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] random32: do not feed jiffies as seed from lpfc driver
Date: Thu, 31 Jul 2014 22:08:37 +0200
Message-ID: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, James Bottomley <JBottomley@Parallels.com>,
	James Smart <james.smart@emulex.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbaGaUIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 16:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In prandom we have already reseeding mechanisms that trigger
periodically from a much better entropy source than just
feeding in jiffies through lpfc_mbx_cmpl_fcf_scan_read_fcf_rec()
[what a function name 8-)]. Therefore, just remove this.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: James Bottomley <JBottomley@Parallels.com>
Cc: James Smart <james.smart@emulex.com>
---
 This can also go via James, how you prefer it.

 drivers/scsi/lpfc/lpfc_hbadisc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/scsi/lpfc/lpfc_hbadisc.c b/drivers/scsi/lpfc/lpfc_hbadisc.c
index 2a17e31..5072bb2 100644
--- a/drivers/scsi/lpfc/lpfc_hbadisc.c
+++ b/drivers/scsi/lpfc/lpfc_hbadisc.c
@@ -2146,7 +2146,6 @@ lpfc_mbx_cmpl_fcf_scan_read_fcf_rec(struct lpfc_hba *phba, LPFC_MBOXQ_t *mboxq)
 	uint16_t fcf_index, next_fcf_index;
 	struct lpfc_fcf_rec *fcf_rec = NULL;
 	uint16_t vlan_id;
-	uint32_t seed;
 	bool select_new_fcf;
 	int rc;
 
@@ -2383,9 +2382,6 @@ lpfc_mbx_cmpl_fcf_scan_read_fcf_rec(struct lpfc_hba *phba, LPFC_MBOXQ_t *mboxq)
 		phba->fcf.fcf_flag |= FCF_AVAILABLE;
 		/* Setup initial running random FCF selection count */
 		phba->fcf.eligible_fcf_cnt = 1;
-		/* Seeding the random number generator for random selection */
-		seed = (uint32_t)(0xFFFFFFFF & jiffies);
-		prandom_seed(seed);
 	}
 	spin_unlock_irq(&phba->hbalock);
 	goto read_next_fcf;
-- 
1.7.11.7
