From: Tim Hansen <devtimhansen@gmail.com>
Subject: [PATCH v3] net/sock: Update sk rcu iterator macro.
Date: Mon, 23 Oct 2017 15:35:58 -0400
Message-ID: <20171023193558.fhjoxerpzq6pqbo7@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com, devtimhansen@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark hlist node in sk rcu iterator as protected by the rcu.
hlist_next_rcu accomplishes this and silences the warnings
sparse throws.

Found with make C=1 net/ipv4/udp.o on linux-next tag 
next-20171009.

Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
---
 include/net/sock.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 64e5ac41b9cf..14c73e8187a6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -737,10 +737,10 @@ static inline void sk_add_bind_node(struct sock *sk,
  *
  */
 #define sk_for_each_entry_offset_rcu(tpos, pos, head, offset)		       \
-	for (pos = rcu_dereference((head)->first);			       \
+	for (pos = rcu_dereference(hlist_first_rcu(head));		       \
 	     pos != NULL &&						       \
 		({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
-	     pos = rcu_dereference(pos->next))
+	     pos = rcu_dereference(hlist_next_rcu(pos)))
 
 static inline struct user_namespace *sk_user_ns(struct sock *sk)
 {
-- 
2.15.0.rc0
