From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib_rules: reorder struct fib_rules fields
Date: Sat, 03 Aug 2013 11:50:35 -0700
Message-ID: <1375555835.4457.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stefan Tomanek <stefan.tomanek@wertarbyte.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:56685 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab3HCSuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 14:50:37 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so1840705pbc.23
        for <netdev@vger.kernel.org>; Sat, 03 Aug 2013 11:50:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Move refcnt, pref, suppress_ifgroup, suppress_prefixlen out of first
cache line, as they are not used in fast path.

Make sure ctarget & fr_net are in first cache line.

(Assuming 64 bit arches and 64 bytes cache lines)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/fib_rules.h |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 9d0fcbaa..4b2b557 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -10,23 +10,25 @@
 
 struct fib_rule {
 	struct list_head	list;
-	atomic_t		refcnt;
 	int			iifindex;
 	int			oifindex;
 	u32			mark;
 	u32			mark_mask;
-	u32			pref;
 	u32			flags;
 	u32			table;
-	int			suppress_ifgroup;
-	int			suppress_prefixlen;
 	u8			action;
+	/* 3 bytes hole, try to use */
 	u32			target;
 	struct fib_rule __rcu	*ctarget;
+	struct net		*fr_net;
+
+	atomic_t		refcnt;
+	u32			pref;
+	int			suppress_ifgroup;
+	int			suppress_prefixlen;
 	char			iifname[IFNAMSIZ];
 	char			oifname[IFNAMSIZ];
 	struct rcu_head		rcu;
-	struct net *		fr_net;
 };
 
 struct fib_lookup_arg {
