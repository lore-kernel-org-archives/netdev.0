From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nfnetlink_queue: Unregister pernet subsys in case of init failure
Date: Mon, 14 Dec 2015 12:25:42 +0100
Message-ID: <1450092346-3281-3-git-send-email-pablo@netfilter.org>
References: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48354 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932306AbbLNL2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 06:28:20 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 61518B5035
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:28:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1AF6BFF132
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:28:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 825C01B3201
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:27:02 +0100 (CET)
In-Reply-To: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Borisov <kernel@kyup.com>

Commit 3bfe049807c2403 ("netfilter: nfnetlink_{log,queue}:
Register pernet in first place") reorganised the initialisation
order of the pernet_subsys to avoid "use-before-initialised"
condition. However, in doing so the cleanup logic in nfnetlink_queue
got botched in that the pernet_subsys wasn't cleaned in case
nfnetlink_subsys_register failed. This patch adds the necessary
cleanup routine call.

Fixes: 3bfe049807c2403 ("netfilter: nfnetlink_{log,queue}: Register pernet in first place")
Signed-off-by: Nikolay Borisov <kernel@kyup.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3e24054..861c661 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1419,6 +1419,7 @@ static int __init nfnetlink_queue_init(void)
 
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
+	unregister_pernet_subsys(&nfnl_queue_net_ops);
 out:
 	return status;
 }
-- 
2.1.4
