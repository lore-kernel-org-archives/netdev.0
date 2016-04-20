From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: bcmsysport: use  __napi_schedule_irqoff()
Date: Wed, 20 Apr 2016 11:37:08 -0700
Message-ID: <1461177429-23553-2-git-send-email-f.fainelli@gmail.com>
References: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32877 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbcDTSjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 14:39:24 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so21052038pff.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:39:24 -0700 (PDT)
In-Reply-To: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both bcm_sysport_tx_isr() and bcm_sysport_rx_isr() run in hard irq
context, we do not need to block irq again.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 993c780bdfab..9e3ec739d860 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -873,7 +873,7 @@ static irqreturn_t bcm_sysport_rx_isr(int irq, void *dev_id)
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			/* disable RX interrupts */
 			intrl2_0_mask_set(priv, INTRL2_0_RDMA_MBDONE);
-			__napi_schedule(&priv->napi);
+			__napi_schedule_irqoff(&priv->napi);
 		}
 	}
 
@@ -916,7 +916,7 @@ static irqreturn_t bcm_sysport_tx_isr(int irq, void *dev_id)
 
 		if (likely(napi_schedule_prep(&txr->napi))) {
 			intrl2_1_mask_set(priv, BIT(ring));
-			__napi_schedule(&txr->napi);
+			__napi_schedule_irqoff(&txr->napi);
 		}
 	}
 
-- 
2.1.0
