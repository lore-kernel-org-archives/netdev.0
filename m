From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 1/9] atl1: handle rx in separate condition
Date: Fri, 13 Apr 2012 20:09:46 +0400
Message-ID: <1334333394-38404-2-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54697 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove rx from unlikely optimization in case of rx is very
likely thing for network card. This also reduce code a bit.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index c926857..6438239 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2502,18 +2502,19 @@ static irqreturn_t atl1_intr(int irq, void *data)
 		if (status & ISR_CMB_TX)
 			atl1_intr_tx(adapter);
 
+		/* rx event */
+		if (status & ISR_CMB_RX)
+			alt1_intr_rx(adapter);
+
 		/* rx exception */
 		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
 			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
-			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-				ISR_HOST_RRD_OV))
-				if (netif_msg_intr(adapter))
-					dev_printk(KERN_DEBUG,
-						&adapter->pdev->dev,
-						"rx exception, ISR = 0x%x\n",
-						status);
+			ISR_HOST_RRD_OV))) {
+			if (netif_msg_intr(adapter))
+				dev_printk(KERN_DEBUG,
+					&adapter->pdev->dev,
+					"rx exception, ISR = 0x%x\n",
+					status);
 			atl1_intr_rx(adapter);
 		}
 
-- 
1.7.1
