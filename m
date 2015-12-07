From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH] netfilter: nfnetlink_queue: Unregister pernet subsys in case of init failure
Date: Mon,  7 Dec 2015 12:13:26 +0200
Message-ID: <1449483206-22618-1-git-send-email-kernel@kyup.com>
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: fruggeri@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37496 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbbLGKNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:13:31 -0500
Received: by wmww144 with SMTP id w144so143332608wmw.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 02:13:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3bfe049807c2403 ('netfilter: nfnetlink_{log,queue}:
Register pernet in first place') reorganised the initialisation
order of the pernet_subsys to avoid "use-before-initialised"
condition. However, in doing so the cleanup logic in nfnetlink_queue
got botched in that the pernet_subsys wasn't cleaned in case
nfnetlink_subsys_register failed. This patch adds the necessary
cleanup routine call.

Fixes: 3bfe049807c2403 ('netfilter: nfnetlink_{log,queue}: Register
						pernet in first place')

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 net/netfilter/nfnetlink_queue.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7d81d280cb4f..2e94603c2dec 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1417,6 +1417,7 @@ static int __init nfnetlink_queue_init(void)
 
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
+	unregister_pernet_subsys(&nfnl_queue_net_ops);
 out:
 	return status;
 }
-- 
2.5.0
