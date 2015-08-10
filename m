From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/2] bnx2x: Prevent null pointer dereference on SKB release
Date: Mon, 10 Aug 2015 12:49:35 +0300
Message-ID: <1439200176-17662-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1439200176-17662-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41002 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753302AbbHJJtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 05:49:46 -0400
In-Reply-To: <1439200176-17662-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On error flows its possible to free an SKB even if it was not allocated.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a90d736..f7fbdc9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -262,9 +262,9 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
 	if (likely(skb)) {
 		(*pkts_compl)++;
 		(*bytes_compl) += skb->len;
+		dev_kfree_skb_any(skb);
 	}
 
-	dev_kfree_skb_any(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
-- 
1.9.3
