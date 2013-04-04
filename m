From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/5] netfilter: nfnetlink_queue: fix error return code in nfnetlink_queue_init()
Date: Thu,  4 Apr 2013 14:56:06 +0200
Message-ID: <1365080169-6880-3-git-send-email-pablo@netfilter.org>
References: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40151 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760835Ab3DDM4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 08:56:41 -0400
In-Reply-To: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 1cb4854..42680b2 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1062,8 +1062,10 @@ static int __init nfnetlink_queue_init(void)
 
 #ifdef CONFIG_PROC_FS
 	if (!proc_create("nfnetlink_queue", 0440,
-			 proc_net_netfilter, &nfqnl_file_ops))
+			 proc_net_netfilter, &nfqnl_file_ops)) {
+		status = -ENOMEM;
 		goto cleanup_subsys;
+	}
 #endif
 
 	register_netdevice_notifier(&nfqnl_dev_notifier);
-- 
1.7.10.4
