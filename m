From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Fix missed MSI workaround
Date: Wed, 31 Aug 2011 14:44:48 -0700
Message-ID: <1314827094-29714-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2318 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a minor counter initialization bug and makes the MSI
workaround slightly more efficient by attempting to service pending
interrupts before applying the workaround.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index de98c10..ab4c598 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8107,7 +8107,7 @@ static void tg3_rings_reset(struct tg3 *tp)
 				tw32_mailbox(tp->napi[i].prodmbox, 0);
 			tw32_rx_mbox(tp->napi[i].consmbox, 0);
 			tw32_mailbox_f(tp->napi[i].int_mbox, 1);
-			tp->napi[0].chk_msi_cnt = 0;
+			tp->napi[i].chk_msi_cnt = 0;
 			tp->napi[i].last_rx_cons = 0;
 			tp->napi[i].last_tx_cons = 0;
 		}
@@ -9187,8 +9187,7 @@ static void tg3_chk_missed_msi(struct tg3 *tp)
 					tnapi->chk_msi_cnt++;
 					return;
 				}
-				tw32_mailbox(tnapi->int_mbox,
-					     tnapi->last_tag << 24);
+				tg3_msi(0, tnapi);
 			}
 		}
 		tnapi->chk_msi_cnt = 0;
-- 
1.7.3.4
