From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 3/4] ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static inline
Date: Tue, 18 Sep 2012 12:29:41 +0800
Message-ID: <1347942582-23962-4-git-send-email-amwang@redhat.com>
References: <1347942582-23962-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015Ab2IREbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 00:31:23 -0400
In-Reply-To: <1347942582-23962-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ipv6.h    |   13 +++++++++++--
 net/ipv6/reassembly.c |   10 ----------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 81d4455..979bf6c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -271,8 +271,17 @@ struct ipv6_txoptions *ipv6_fixup_options(struct i=
pv6_txoptions *opt_space,
=20
 extern bool ipv6_opt_accepted(const struct sock *sk, const struct sk_b=
uff *skb);
=20
-int ip6_frag_nqueues(struct net *net);
-int ip6_frag_mem(struct net *net);
+#if IS_ENABLED(CONFIG_IPV6)
+static inline int ip6_frag_nqueues(struct net *net)
+{
+	return net->ipv6.frags.nqueues;
+}
+
+static inline int ip6_frag_mem(struct net *net)
+{
+	return atomic_read(&net->ipv6.frags.mem);
+}
+#endif
=20
 #define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
 #define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 8508c8c..cac690c 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -67,16 +67,6 @@ struct ip6frag_skb_cb
=20
 static struct inet_frags ip6_frags;
=20
-int ip6_frag_nqueues(struct net *net)
-{
-	return net->ipv6.frags.nqueues;
-}
-
-int ip6_frag_mem(struct net *net)
-{
-	return atomic_read(&net->ipv6.frags.mem);
-}
-
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 			  struct net_device *dev);
=20
--=20
1.7.7.6
