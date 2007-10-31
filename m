From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 7/8] Remove bogus zero_it argument from sk_alloc
Date: Wed, 31 Oct 2007 16:56:10 +0300
Message-ID: <4728897A.50607@openvz.org>
References: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37529 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756709AbXJaMxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 08:53:52 -0400
In-Reply-To: <472885B1.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At this point nobody calls the sk_alloc(() with zero_it == 0,
so remove unneeded checks from it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/sock.c b/net/core/sock.c
index c032f48..77575c3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -931,21 +931,16 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 {
 	struct sock *sk;
 
-	if (zero_it)
-		priority |= __GFP_ZERO;
-
-	sk = sk_prot_alloc(prot, priority, family);
+	sk = sk_prot_alloc(prot, priority | __GFP_ZERO, family);
 	if (sk) {
-		if (zero_it) {
-			sk->sk_family = family;
-			/*
-			 * See comment in struct sock definition to understand
-			 * why we need sk_prot_creator -acme
-			 */
-			sk->sk_prot = sk->sk_prot_creator = prot;
-			sock_lock_init(sk);
-			sk->sk_net = get_net(net);
-		}
+		sk->sk_family = family;
+		/*
+		 * See comment in struct sock definition to understand
+		 * why we need sk_prot_creator -acme
+		 */
+		sk->sk_prot = sk->sk_prot_creator = prot;
+		sock_lock_init(sk);
+		sk->sk_net = get_net(net);
 	}
 
 	return sk;
-- 
1.5.3.4

