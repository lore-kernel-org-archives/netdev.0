From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 1/2] cxgb4: Fix tx flit calculation
Date: Tue,  8 Sep 2015 16:25:39 +0530
Message-ID: <1441709740-7533-2-git-send-email-hariprasad@chelsio.com>
References: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22902 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753254AbbIHKzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 06:55:43 -0400
In-Reply-To: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 0aac3f56d4a63f04 ("cxgb4: Add comment for calculate tx flits
and sge length code") introduced a regression where tx flit calculation
is going wrong, which can lead to data corruption, hang, stall and
write-combining failure. Fixing it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 78f446c..9162746 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -807,7 +807,7 @@ static inline unsigned int calc_tx_flits(const struct sk_buff *skb)
 	 * message or, if we're doing a Large Send Offload, an LSO CPL message
 	 * with an embedded TX Packet Write CPL message.
 	 */
-	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1) + 4;
+	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1);
 	if (skb_shinfo(skb)->gso_size)
 		flits += (sizeof(struct fw_eth_tx_pkt_wr) +
 			  sizeof(struct cpl_tx_pkt_lso_core) +
-- 
2.3.4
