From: Tim Hansen <devtimhansen@gmail.com>
Subject: [PATCH v2] net/sock: Update sk rcu iterator macro.
Date: Mon, 23 Oct 2017 11:39:22 -0400
Message-ID: <20171023153922.orgvwmuvokv6xbi4@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com, devtimhansen@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:52958 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932126AbdJWPj3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:39:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark hlist nodes in sk rcu iterator as protected by the rcu.
hlist_next_rcu accomplishes this and silences the warnings
sparse throws for net/ipv4/udp.c and net/ipv6/udp.c.

Found with make C=1 net/ipv4/udp.o on linux-next tag 
next-20171009.

Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
---
 include/net/sock.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 64e5ac41b9cf..96cb7b7e4924 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -737,10 +737,10 @@ static inline void sk_add_bind_node(struct sock *sk,
  *
  */
 #define sk_for_each_entry_offset_rcu(tpos, pos, head, offset)		       \
-	for (pos = rcu_dereference((head)->first);			       \
+	for (pos = rcu_dereference(hlist_next_rcu((head)->first));	       \
 	     pos != NULL &&						       \
 		({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
-	     pos = rcu_dereference(pos->next))
+	     pos = rcu_dereference(hlist_next_rcu(pos->next)))
 
 static inline struct user_namespace *sk_user_ns(struct sock *sk)
 {
-- 
2.15.0.rc0
