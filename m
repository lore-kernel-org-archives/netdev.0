From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH] net: remove unnecessary initializations in net_dev_init
Date: Sat, 18 Jan 2014 16:04:11 +0100
Message-ID: <1390057451-30807-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:41747 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbaARPFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 10:05:38 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id CE0662CE69
	for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 16:05:32 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

softnet_data is set to 0 by memset, no need to initialize specific
fields to 0 or NULL afterwards.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/core/dev.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 288df62..b57b44a2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7000,25 +7000,16 @@ static int __init net_dev_init(void)
 		memset(sd, 0, sizeof(*sd));
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
