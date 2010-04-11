From: kaber@trash.net
Subject: [RFC PATCH 4/9] ipv4: raw: move struct raw_sock and raw_sk() to include/net/raw.h
Date: Sun, 11 Apr 2010 19:37:10 +0200
Message-ID: <1271007435-20035-5-git-send-email-kaber@trash.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37502 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab0DKRhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 13:37:20 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by stinky.trash.net (Postfix) with ESMTP id 5C136B2C50
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 19:37:19 +0200 (MEST)
In-Reply-To: <1271007435-20035-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

A following patch will use struct raw_sock to store state for ipmr,
so having the definitions in icmp.h doesn't fit very well anymore.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/icmp.h |   11 -----------
 include/net/raw.h  |   12 ++++++++++++
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 15b3dfe..6e991e0 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -48,15 +48,4 @@ extern void	icmp_out_count(struct net *net, unsigned char type);
 /* Move into dst.h ? */
 extern int 	xrlim_allow(struct dst_entry *dst, int timeout);
 
-struct raw_sock {
-	/* inet_sock has to be the first member */
-	struct inet_sock   inet;
-	struct icmp_filter filter;
-};
-
-static inline struct raw_sock *raw_sk(const struct sock *sk)
-{
-	return (struct raw_sock *)sk;
-}
-
 #endif	/* _ICMP_H */
diff --git a/include/net/raw.h b/include/net/raw.h
index 6c14a65..67cc643 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -19,6 +19,7 @@
 
 
 #include <net/protocol.h>
+#include <linux/icmp.h>
 
 extern struct proto raw_prot;
 
@@ -56,4 +57,15 @@ int raw_seq_open(struct inode *ino, struct file *file,
 void raw_hash_sk(struct sock *sk);
 void raw_unhash_sk(struct sock *sk);
 
+struct raw_sock {
+	/* inet_sock has to be the first member */
+	struct inet_sock   inet;
+	struct icmp_filter filter;
+};
+
+static inline struct raw_sock *raw_sk(const struct sock *sk)
+{
+	return (struct raw_sock *)sk;
+}
+
 #endif	/* _RAW_H */
-- 
1.7.0.4

