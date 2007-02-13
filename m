From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 4/8]: 5906 doesn't need to switch to slower clock.
Date: Tue, 13 Feb 2007 12:14:20 -0800
Message-ID: <1171397660.18944.28.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1823 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804AbXBMTbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:31:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: 5906 doesn't need to switch to slower clock.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fc94b19..b6615f1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1340,7 +1340,8 @@ static int tg3_set_power_state(struct tg
 
 		tw32_wait_f(TG3PCI_CLOCK_CTRL, base_val | CLOCK_CTRL_ALTCLK |
 			    CLOCK_CTRL_PWRDOWN_PLL133, 40);
-	} else if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
+	} else if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
+		   (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)) {
 		/* do nothing */
 	} else if (!((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
 		     (tp->tg3_flags & TG3_FLAG_ENABLE_ASF))) {


