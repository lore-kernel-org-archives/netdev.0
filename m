From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/2 net-next] batman-adv: fix global TT entry deletion
Date: Tue, 26 Jun 2012 08:49:51 +0200
Message-ID: <1340693391-16434-3-git-send-email-ordex@autistici.org>
References: <20120625.161933.730861831753419928.davem@davemloft.net>
 <1340693391-16434-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:38562 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711Ab2FZGtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 02:49:39 -0400
In-Reply-To: <1340693391-16434-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the last merge involving translation-table.c something went wrong and two
lines disappeared from translation-table.c. This patch recovers them.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index e4f27a8..c673b58 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -149,6 +149,8 @@ static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
 static void
 batadv_tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_entry)
 {
+	/* to avoid race conditions, immediately decrease the tt counter */
+	atomic_dec(&orig_entry->orig_node->tt_size);
 	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
 }
 
-- 
1.7.9.4
