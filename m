From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/10] tg3: Reenable TSS for 5719
Date: Wed, 24 Nov 2010 10:31:51 -0800
Message-ID: <1290623514-18193-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3959 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab0KXScN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All TSS bugs have been fixed in the 5719.  This patch reenables the
feature.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4fa8ee3..75ebebc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9037,8 +9037,14 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		pci_disable_msix(tp->pdev);
 		return false;
 	}
-	if (tp->irq_cnt > 1)
+
+	if (tp->irq_cnt > 1) {
 		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+			tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
+			netif_set_real_num_tx_queues(tp->dev, tp->irq_cnt - 1);
+		}
+	}
 
 	return true;
 }
-- 
1.7.2.2


