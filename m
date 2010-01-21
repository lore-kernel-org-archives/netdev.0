From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 09/10] tg3: Bypass power source switching for
 57765
Date: Wed, 20 Jan 2010 18:58:10 -0800
Message-ID: <1264042691-28284-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1380 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753735Ab0AUC6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 57765 repurposes all the GPIOs normally used to switch power sources
when configured as a NIC device.  This patch changes the code to avoid
touching the GPIOs for this asic rev.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 075d21a..7810202 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2021,7 +2021,9 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 {
 	struct tg3 *tp_peer = tp;
 
-	if ((tp->tg3_flags2 & TG3_FLG2_IS_NIC) == 0)
+	/* The GPIOs do something completely different on 57765. */
+	if ((tp->tg3_flags2 & TG3_FLG2_IS_NIC) == 0 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		return;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
-- 
1.6.4.4


