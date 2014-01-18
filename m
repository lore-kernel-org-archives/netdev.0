From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2] net: remove unnecessary initializations in net_dev_init
Date: Sat, 18 Jan 2014 19:19:27 +0100
Message-ID: <1390069167-14080-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:37431 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbaARSTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 13:19:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

softnet_data is already set to 0, no need to use memset or initialize
specific fields to 0 or NULL afterwards.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---

v2: remove memset as well, since as Eric said, percpu data is 0 at
    boot time

 net/core/dev.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 288df62..36c0cc69 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6997,28 +6997,18 @@ static int __init net_dev_init(void)
 	for_each_possible_cpu(i) {
 		struct softnet_data *sd = &per_cpu(softnet_data, i);
 
-		memset(sd, 0, sizeof(*sd));
 		skb_queue_head_init(&sd->input_pkt_queue);
 		skb_queue_head_init(&sd->process_queue);
-		sd->completion_queue = NULL;
 		INIT_LIST_HEAD(&sd->poll_list);
-		sd->output_queue = NULL;
 		sd->output_queue_tailp = &sd->output_queue;
 #ifdef CONFIG_RPS
 		sd->csd.func = rps_trigger_softirq;
 		sd->csd.info = sd;
-		sd->csd.flags = 0;
 		sd->cpu = i;
 #endif
 
 		sd->backlog.poll = process_backlog;
 		sd->backlog.weight = weight_p;
-		sd->backlog.gro_list = NULL;
-		sd->backlog.gro_count = 0;
-
-#ifdef CONFIG_NET_FLOW_LIMIT
-		sd->flow_limit = NULL;
-#endif
 	}
 
 	dev_boot_phase = 0;
-- 
1.8.5.3
