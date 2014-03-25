From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 05/54] bfin_mac: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:51 -0700
Message-ID: <1395727540-12148-5-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58470 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaCYGGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:13 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in _tx_reclaim_skb that
can be called in hard irq and other contexts.

dev_consume_skb is used as _tx_reclaim_skb is called after a packet
has been successfully transmitted.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 83a8cdbcd936..95779b6b7394 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1087,7 +1087,7 @@ static inline void _tx_reclaim_skb(void)
 		tx_list_head->desc_a.config &= ~DMAEN;
 		tx_list_head->status.status_word = 0;
 		if (tx_list_head->skb) {
-			dev_kfree_skb(tx_list_head->skb);
+			dev_consume_skb_any(tx_list_head->skb);
 			tx_list_head->skb = NULL;
 		}
 		tx_list_head = tx_list_head->next;
-- 
1.7.10.4
