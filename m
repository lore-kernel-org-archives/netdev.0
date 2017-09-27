From: Tim Hansen <devtimhansen@gmail.com>
Subject: [PATCH] net/ipv4: Update sk_for_each_entry_offset_rcu macro to  utilize rcu methods hlist_next_rcu. This fixes the warnings thrown by sparse  regarding net/ipv4/udp.c on line 1974.
Date: Tue, 26 Sep 2017 20:54:05 -0400
Message-ID: <20170927005406.5935-1-devtimhansen@gmail.com>
Cc: Tim Hansen <devtimhansen@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
---
 include/net/sock.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index aeeec62992ca..516289f6404b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -732,10 +732,10 @@ static inline void sk_add_bind_node(struct sock *sk,
  *
  */
 #define sk_for_each_entry_offset_rcu(tpos, pos, head, offset)		       \
-	for (pos = rcu_dereference((head)->first);			       \
+	for (pos = rcu_dereference_raw(hlist_next_rcu((head)->first));	       \
 	     pos != NULL &&						       \
 		({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
-	     pos = rcu_dereference(pos->next))
+	     pos = rcu_dereference_raw(hlist_next_rcu(pos->next)))
 
 static inline struct user_namespace *sk_user_ns(struct sock *sk)
 {
-- 
2.14.1
