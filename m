From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/22] netfilter: bridge: remove unneeded rcu_read_lock
Date: Mon, 20 Mar 2017 11:08:36 +0100
Message-ID: <1490004530-9128-9-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52088 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754036AbdCTKJk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:40 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0B9F3523EC
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EE908DA874
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B0802DA863
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:06 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

as comment says, the function is always called with rcu read lock held.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 95087e6e8258..52739e6c610e 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -1016,13 +1016,10 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
 	if (!elem)
 		return okfn(net, sk, skb);
 
-	/* We may already have this, but read-locks nest anyway */
-	rcu_read_lock();
 	nf_hook_state_init(&state, hook, NFPROTO_BRIDGE, indev, outdev,
 			   sk, net, okfn);
 
 	ret = nf_hook_slow(skb, &state, elem);
-	rcu_read_unlock();
 	if (ret == 1)
 		ret = okfn(net, sk, skb);
 
-- 
2.1.4
