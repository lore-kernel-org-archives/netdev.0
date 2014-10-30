From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: use napi_schedule_irqoff()
Date: Wed, 29 Oct 2014 17:07:50 -0700
Message-ID: <1414627670.631.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:48607 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbaJ3AHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 20:07:48 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so3918488pdj.26
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 17:07:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bnx2x_msix_fp_int() and bnx2x_interrupt() run from hard interrupt
context.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 40beef5bca88ade51dd5248550c45059b8774476..e9af4af5edbaf2e464a2250038e0505aafbbcd06 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1139,7 +1139,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 		prefetch(fp->txdata_ptr[cos]->tx_cons_sb);
 
 	prefetch(&fp->sb_running_index[SM_RX_ID]);
-	napi_schedule(&bnx2x_fp(bp, fp->index, napi));
+	napi_schedule_irqoff(&bnx2x_fp(bp, fp->index, napi));
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 74fbf9ea7bd878e4ee3f7d1561f4b74afe46ca54..c4bd025c74c96496a4709a4505da8a2d0f028df4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1931,7 +1931,7 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 			for_each_cos_in_tx_queue(fp, cos)
 				prefetch(fp->txdata_ptr[cos]->tx_cons_sb);
 			prefetch(&fp->sb_running_index[SM_RX_ID]);
-			napi_schedule(&bnx2x_fp(bp, fp->index, napi));
+			napi_schedule_irqoff(&bnx2x_fp(bp, fp->index, napi));
 			status &= ~mask;
 		}
 	}
