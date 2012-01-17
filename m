From: pablo@netfilter.org
Subject: [PATCH 4/4] netfilter: ipset: dumping error triggered removing references twice
Date: Tue, 17 Jan 2012 12:04:49 +0100
Message-ID: <1326798289-11592-5-git-send-email-pablo@netfilter.org>
References: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32811 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456Ab2AQLFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 06:05:17 -0500
In-Reply-To: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

If there was a dumping error in the middle, the set-specific variable was
not zeroed out and thus the 'done' function of the dumping wrongly tried
to release the already released reference of the set. The already released
reference was caught by __ip_set_put and triggered a kernel BUG message.
Reported by Jean-Philippe Menil.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 0f8e5f2..32dbf0f 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1142,6 +1142,7 @@ release_refcount:
 	if (ret || !cb->args[2]) {
 		pr_debug("release set %s\n", ip_set_list[index]->name);
 		ip_set_put_byindex(index);
+		cb->args[2] = 0;
 	}
 out:
 	if (nlh) {
-- 
1.7.7.3
