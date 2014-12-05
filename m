From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Fri,  5 Dec 2014 17:49:08 +0800
Message-ID: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40690 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbaLEJtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 04:49:14 -0500
Received: by mail-pd0-f176.google.com with SMTP id y10so392110pdj.21
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 01:49:14 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id xq16sm19432135pac.31.2014.12.05.01.49.12
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Dec 2014 01:49:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

the queue length of sd->input_pkt_queue has been putted into qlen,
and impossible to change, since hold the lock

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
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
