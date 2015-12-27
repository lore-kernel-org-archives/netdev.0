From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 04/12] bnxt_en: Increment checksum error counter only if NETIF_F_RXCSUM is set.
Date: Sun, 27 Dec 2015 18:19:21 -0500
Message-ID: <1451258369-21543-5-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:44954 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584AbbL0XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:30 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Baddipadige <sbaddipa@broadcom.com>

rx_l4_csum_error is now incremented only when offload is enabled

Signed-off-by: Satish Baddipadige <sbaddipa@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e340fb3..3ce3bd3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1187,8 +1187,10 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 			skb->csum_level = RX_CMP_ENCAP(rxcmp1);
 		}
 	} else {
-		if (rxcmp1->rx_cmp_cfa_code_errors_v2 & RX_CMP_L4_CS_ERR_BITS)
-			cpr->rx_l4_csum_errors++;
+		if (rxcmp1->rx_cmp_cfa_code_errors_v2 & RX_CMP_L4_CS_ERR_BITS) {
+			if (dev->features & NETIF_F_RXCSUM)
+				cpr->rx_l4_csum_errors++;
+		}
 	}
 
 	skb_record_rx_queue(skb, bnapi->index);
-- 
1.8.3.1
