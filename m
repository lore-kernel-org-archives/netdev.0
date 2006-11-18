From: Paul Bonser <misterpib@gmail.com>
Subject: [PATCH] Networking: re-fix of doc-comment in sock.h
Date: Sat, 18 Nov 2006 00:27:27 -0800
Message-ID: <20061118082727.GA1250@pib>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-24-21-154-103.hsd1.or.comcast.net ([24.21.154.103]:62413 "EHLO
	p1b.net") by vger.kernel.org with ESMTP id S1754265AbWKRIV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Nov 2006 03:21:59 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bonser <misterpib@gmail.com>

Restoring old, correct comment for sk_filter_release, moving it to where it should actually be, and changing new comment into proper comment for sk_filter_rcu_free, where it actually makes sense.

The original fix submitted for this on Oct 23 mistakenly documented the wrong function.

Signed-off-by: Paul Bonser <misterpib@gmail.com>

---

diff --git a/include/net/sock.h b/include/net/sock.h
index ac286a3..9cdbae2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -883,18 +883,23 @@ static inline int sk_filter(struct sock 
 }
 
 /**
- *	sk_filter_release: Release a socket filter
- *	@rcu: rcu_head that contains the sk_filter info to remove
- *
- *	Remove a filter from a socket and release its resources.
+ * 	sk_filter_rcu_free: Free a socket filter
+ *	@rcu: rcu_head that contains the sk_filter to free
  */
- 
 static inline void sk_filter_rcu_free(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 	kfree(fp);
 }
 
+/**
+ *	sk_filter_release: Release a socket filter
+ *	@sk: socket
+ *	@fp: filter to remove
+ *
+ *	Remove a filter from a socket and release its resources.
+ */
+
 static inline void sk_filter_release(struct sock *sk, struct sk_filter *fp)
 {
 	unsigned int size = sk_filter_len(fp);
