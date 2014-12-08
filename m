From: roy.qing.li@gmail.com
Subject: [PATCH][net-next][V2] net: avoid to call skb_queue_len again
Date: Mon,  8 Dec 2014 09:42:55 +0800
Message-ID: <1418002975-15271-1-git-send-email-roy.qing.li@gmail.com>
Cc: edumazet@google.com, sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:43573 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaLHBnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 20:43:01 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so3817694pdb.19
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 17:43:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

the queue length of sd->input_pkt_queue has been put into qlen,
and impossible to change, since hold the lock

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0814a56..b954400 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3297,7 +3297,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	rps_lock(sd);
 	qlen = skb_queue_len(&sd->input_pkt_queue);
 	if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen)) {
-		if (skb_queue_len(&sd->input_pkt_queue)) {
+		if (qlen) {
 enqueue:
 			__skb_queue_tail(&sd->input_pkt_queue, skb);
 			input_queue_tail_incr_save(sd, qtail);
-- 
2.1.0
