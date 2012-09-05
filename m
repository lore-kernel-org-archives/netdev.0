From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ath6kl: use list_move_tail instead of list_del/list_add_tail
Date: Wed, 5 Sep 2012 15:07:29 +0800
Message-ID: <CAPgLHd-6RmrLpi9FPTFhXiA+BHywGknmvNAd-KCdHaM+tn0qgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: kvalo@qca.qualcomm.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41477 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287Ab2IEHH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 03:07:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move_tail() instead of list_del() + list_add_tail().

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/ath/ath6kl/htc_pipe.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index f9626c7..ba6bd49 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -374,9 +374,8 @@ static enum htc_send_queue_result htc_try_send(struct htc_target *target,
 				packet = list_first_entry(txq,
 							  struct htc_packet,
 							  list);
-				list_del(&packet->list);
-				/* insert into local queue */
-				list_add_tail(&packet->list, &send_queue);
+				/* move to local queue */
+				list_move_tail(&packet->list, &send_queue);
 			}
 
 			/*
@@ -399,11 +398,10 @@ static enum htc_send_queue_result htc_try_send(struct htc_target *target,
 					 * for cleanup */
 				} else {
 					/* callback wants to keep this packet,
-					 * remove from caller's queue */
-					list_del(&packet->list);
-					/* put it in the send queue */
-					list_add_tail(&packet->list,
-						      &send_queue);
+					 * move from caller's queue to the send
+					 * queue */
+					list_move_tail(&packet->list,
+						       &send_queue);
 				}
 
 			}
