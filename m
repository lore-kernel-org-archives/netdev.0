From: Chang Xiangzhong <changxiangzhong@gmail.com>
Subject: [PATCH] net: sctp: set chunk->tsn_gap_acked at the end of cycle
Date: Fri, 22 Nov 2013 08:49:49 +0100
Message-ID: <1385106589-402-1-git-send-email-changxiangzhong@gmail.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Chang Xiangzhong <changxiangzhong@gmail.com>
To: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tsn_gap_acked is an important state flag in chunk, which indicates if the
chunk has been acked in gap reports before. SFR-CACC algorithm depends on this
variable. So set this at the end of each iteration, otherwise the SFR-CACC
algorithm would never be toggled.

Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>
---
 net/sctp/outqueue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 1b494fa..bff828c 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1396,7 +1396,6 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 			 * while DATA was outstanding).
 			 */
 			if (!tchunk->tsn_gap_acked) {
-				tchunk->tsn_gap_acked = 1;
 				if (TSN_lt(*highest_new_tsn_in_sack, tsn))
 					*highest_new_tsn_in_sack = tsn;
 				bytes_acked += sctp_data_size(tchunk);
@@ -1460,6 +1459,8 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				 */
 				list_add_tail(lchunk, &tlist);
 			}
+
+			tchunk->tsn_gap_acked = 1;
 		} else {
 			if (tchunk->tsn_gap_acked) {
 				pr_debug("%s: receiver reneged on data TSN:0x%x\n",
-- 
1.8.4.3
