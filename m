From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 1/9] bnx2x: added 'likely' to fast-path skb existence
Date: Sun, 18 Mar 2012 16:33:37 -0400
Message-ID: <1332102825-7838-2-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1278 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab2CRNsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:20 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c11e50d..d40c76a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -120,10 +120,11 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
 
 	/* release skb */
 	WARN_ON(!skb);
-	if (skb) {
+	if (likely(skb)) {
 		(*pkts_compl)++;
 		(*bytes_compl) += skb->len;
 	}
+
 	dev_kfree_skb_any(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
-- 
1.7.9.rc2
