From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/15] batman-adv: prevent potential hlist double deletion
Date: Tue, 25 Aug 2015 13:02:32 +0200
Message-ID: <1440500559-28368-9-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:2291 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755448AbbHYLEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:04:01 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

The hlist_del_rcu() call in batadv_tt_global_size_mod() does not check
if the element still is part of the list prior to deletion. The atomic
list counter should prevent the worst but converting to
hlist_del_init_rcu() ensures the element can't be deleted more than
once.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 9e1f866..596e326 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -315,7 +315,7 @@ static void batadv_tt_global_size_mod(struct batadv_orig_node *orig_node,
 
 	if (atomic_add_return(v, &vlan->tt.num_entries) == 0) {
 		spin_lock_bh(&orig_node->vlan_list_lock);
-		hlist_del_rcu(&vlan->list);
+		hlist_del_init_rcu(&vlan->list);
 		spin_unlock_bh(&orig_node->vlan_list_lock);
 		batadv_orig_node_vlan_free_ref(vlan);
 	}
-- 
2.5.0
