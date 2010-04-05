From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/12] tg3: Restore likely() check in
 tg3_poll_msix()
Date: Mon, 5 Apr 2010 13:19:20 -0700
Message-ID: <1270498770-23765-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2377 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756440Ab0DEUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating the new tg3_poll_msix() function, the likely() compiler
hint was dropped.  This patch reintroduces it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 22cf1c4..53c52e8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4987,8 +4987,8 @@ static int tg3_poll_msix(struct napi_struct *napi, int budget)
 		rmb();
 
 		/* check for RX/TX work to do */
-		if (sblk->idx[0].tx_consumer == tnapi->tx_cons &&
-		    *(tnapi->rx_rcb_prod_idx) == tnapi->rx_rcb_ptr) {
+		if (likely(sblk->idx[0].tx_consumer == tnapi->tx_cons &&
+			   *(tnapi->rx_rcb_prod_idx) == tnapi->rx_rcb_ptr)) {
 			napi_complete(napi);
 			/* Reenable interrupts. */
 			tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
-- 
1.6.4.4


