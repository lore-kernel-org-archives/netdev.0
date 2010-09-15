From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/9] tg3: Disable TSS
Date: Wed, 15 Sep 2010 11:59:54 -0700
Message-ID: <1284577201-6117-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2586 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab0IOTAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 15:00:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was recently discovered that enabling TSS can lockup the device.
This patch disables the feature until a suitable workaround can be
found.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c3a430c..38f1b19 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8827,16 +8827,9 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
 
 	tp->dev->real_num_tx_queues = 1;
-	if (tp->irq_cnt > 1) {
+	if (tp->irq_cnt > 1)
 		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
-			tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
-			tp->dev->real_num_tx_queues = tp->irq_cnt - 1;
-		}
-	}
-
 	return true;
 }
 
-- 
1.7.1


