From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 6/8] tg3: Appropriately classify interrupts
 during request_irq
Date: Fri, 20 Sep 2013 16:47:00 -0700
Message-ID: <1379720822-6500-7-git-send-email-nsujir@broadcom.com>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4373 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab3ITXr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:26 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Distinguish between tx, rx and txrx interrupts.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e56e4f8..b0dd391 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11038,7 +11038,18 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
 		name = tp->dev->name;
 	else {
 		name = &tnapi->irq_lbl[0];
-		snprintf(name, IFNAMSIZ, "%s-%d", tp->dev->name, irq_num);
+		if (tnapi->tx_buffers && tnapi->rx_rcb)
+			snprintf(name, IFNAMSIZ,
+				 "%s-txrx-%d", tp->dev->name, irq_num);
+		else if (tnapi->tx_buffers)
+			snprintf(name, IFNAMSIZ,
+				 "%s-tx-%d", tp->dev->name, irq_num);
+		else if (tnapi->rx_rcb)
+			snprintf(name, IFNAMSIZ,
+				 "%s-rx-%d", tp->dev->name, irq_num);
+		else
+			snprintf(name, IFNAMSIZ,
+				 "%s-%d", tp->dev->name, irq_num);
 		name[IFNAMSIZ-1] = 0;
 	}
 
-- 
1.8.1.4
