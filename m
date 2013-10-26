From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2 2/3] sctp: remove the repeat initialize with 0
Date: Sat, 26 Oct 2013 16:06:31 +0800
Message-ID: <1382774792-13440-3-git-send-email-wangweidong1@huawei.com>
References: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:39980 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3JZIHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 04:07:01 -0400
In-Reply-To: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kmem_cache_zalloc had set the allocated memory to zero. I think no need
to initialize with 0. And move the comments to the function begin.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sm_make_chunk.c | 29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index d244a23..fe69032 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1297,6 +1297,13 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
 
 /* Turn an skb into a chunk.
  * FIXME: Eventually move the structure directly inside the skb->cb[].
+ *
+ * sctpimpguide-05.txt Section 2.8.2
+ * M1) Each time a new DATA chunk is transmitted
+ * set the 'TSN.Missing.Report' count for that TSN to 0. The
+ * 'TSN.Missing.Report' count will be used to determine missing chunks
+ * and when to fast retransmit.
+ *
  */
 struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
 			    const struct sctp_association *asoc,
@@ -1314,29 +1321,9 @@ struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
 	INIT_LIST_HEAD(&retval->list);
 	retval->skb		= skb;
 	retval->asoc		= (struct sctp_association *)asoc;
-	retval->has_tsn		= 0;
-	retval->has_ssn         = 0;
-	retval->rtt_in_progress	= 0;
-	retval->sent_at		= 0;
 	retval->singleton	= 1;
-	retval->end_of_packet	= 0;
-	retval->ecn_ce_done	= 0;
-	retval->pdiscard	= 0;
-
-	/* sctpimpguide-05.txt Section 2.8.2
-	 * M1) Each time a new DATA chunk is transmitted
-	 * set the 'TSN.Missing.Report' count for that TSN to 0. The
-	 * 'TSN.Missing.Report' count will be used to determine missing chunks
-	 * and when to fast retransmit.
-	 */
-	retval->tsn_missing_report = 0;
-	retval->tsn_gap_acked = 0;
-	retval->fast_retransmit = SCTP_CAN_FRTX;
 
-	/* If this is a fragmented message, track all fragments
-	 * of the message (for SEND_FAILED).
-	 */
-	retval->msg = NULL;
+	retval->fast_retransmit = SCTP_CAN_FRTX;
 
 	/* Polish the bead hole.  */
 	INIT_LIST_HEAD(&retval->transmitted_list);
-- 
1.7.12
