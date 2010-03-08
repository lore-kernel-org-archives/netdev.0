From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] net: add __must_check to sk_add_backlog
Date: Mon,  8 Mar 2010 10:21:39 +0800
Message-ID: <1268014899-31318-1-git-send-email-yi.zhu@intel.com>
Cc: netdev@vger.kernel.org, Zhu Yi <yi.zhu@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28284 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241Ab0CHCUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Mar 2010 21:20:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the "__must_check" tag to sk_add_backlog() so that any failure to
check and drop packets will be warned about.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 include/net/sock.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 170353d..092b055 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -604,7 +604,7 @@ static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 }
 
 /* The per-socket spinlock must be held here. */
-static inline int sk_add_backlog(struct sock *sk, struct sk_buff *skb)
+static inline __must_check int sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	if (sk->sk_backlog.len >= max(sk->sk_backlog.limit, sk->sk_rcvbuf << 1))
 		return -ENOBUFS;
-- 
1.6.3.3

