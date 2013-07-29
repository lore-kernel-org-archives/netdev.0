From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Remove incorrect switch to aux power
Date: Mon, 29 Jul 2013 13:58:35 -0700
Message-ID: <1375131520-1746-2-git-send-email-nsujir@broadcom.com>
References: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2626 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab3G2U6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:58:54 -0400
In-Reply-To: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During probe, the driver is incorrectly switching the power to Vaux on
the 5717 and later devices. At this point, we are in D0 state and
drawing maximum power. We also definitely have Vmain available. It
doesn't make sense to switch to Vaux since it has a lesser maximum power
draw and we might go over the limit. On a new system, we observe that
not all ports are recognized in some of the slots with this call in
place.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d964f30..2e4bf5f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17547,11 +17547,6 @@ static int tg3_init_one(struct pci_dev *pdev,
 	    tg3_asic_rev(tp) == ASIC_REV_5762)
 		tg3_flag_set(tp, PTP_CAPABLE);
 
-	if (tg3_flag(tp, 5717_PLUS)) {
-		/* Resume a low-power mode */
-		tg3_frob_aux_power(tp, false);
-	}
-
 	tg3_timer_init(tp);
 
 	tg3_carrier_off(tp);
-- 
1.8.1.4
