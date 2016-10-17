From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] qed: Use list_move_tail instead of list_del/list_add_tail
Date: Mon, 17 Oct 2016 15:17:51 +0000
Message-ID: <1476717471-16261-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, everest-linux-l2@qlogic.com,
        netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36382 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932551AbcJQPSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:18:00 -0400
Received: by mail-pf0-f193.google.com with SMTP id r16so12975128pfg.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 08:17:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Using list_move_tail() instead of list_del() + list_add_tail().

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index a6db107..a249c1d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -537,8 +537,7 @@ void qed_ll2_rxq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 		if (!p_pkt)
 			break;
 
-		list_del(&p_pkt->list_entry);
-		list_add_tail(&p_pkt->list_entry, &p_rx->free_descq);
+		list_move_tail(&p_pkt->list_entry, &p_rx->free_descq);
 
 		rx_buf_addr = p_pkt->rx_buf_addr;
 		cookie = p_pkt->cookie;
@@ -992,9 +991,8 @@ static void qed_ll2_post_rx_buffer_notify_fw(struct qed_hwfn *p_hwfn,
 		p_posting_packet = list_first_entry(&p_rx->posting_descq,
 						    struct qed_ll2_rx_packet,
 						    list_entry);
-		list_del(&p_posting_packet->list_entry);
-		list_add_tail(&p_posting_packet->list_entry,
-			      &p_rx->active_descq);
+		list_move_tail(&p_posting_packet->list_entry,
+			       &p_rx->active_descq);
 		b_notify_fw = true;
 	}
 
@@ -1188,8 +1186,7 @@ static void qed_ll2_tx_packet_notify(struct qed_hwfn *p_hwfn,
 		if (!p_pkt)
 			break;
 
-		list_del(&p_pkt->list_entry);
-		list_add_tail(&p_pkt->list_entry, &p_tx->active_descq);
+		list_move_tail(&p_pkt->list_entry, &p_tx->active_descq);
 	}
 
 	SET_FIELD(db_msg.params, CORE_DB_DATA_DEST, DB_DEST_XCM);
