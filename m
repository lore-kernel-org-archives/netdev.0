From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 8/8] benet: Fix interval calculation in interrupt moderation
Date: Tue,  2 Feb 2016 15:50:35 +0530
Message-ID: <1454408435-11575-9-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754579AbcBBKjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:31 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>

Interrupt moderation parameters need to be recalculated only
after a time interval of 1 ms. Interval calculation is wrong
when there is a rollover of jiffies. Using recommended way of interval
calculation using jiffies to fix this.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d5286d3..9c1fc9d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1917,8 +1917,7 @@ static u32 be_get_eq_delay_mult_enc(struct be_eq_obj *eqo)
 	if (!aic->enable)
 		return 0;
 
-	if (time_before_eq(now, aic->jiffies) ||
-	    jiffies_to_msecs(now - aic->jiffies) < 1)
+	if (jiffies_to_msecs(now - aic->jiffies) < 1)
 		eqd = aic->prev_eqd;
 	else
 		eqd = be_get_new_eqd(eqo);
-- 
2.3.0.rc2
