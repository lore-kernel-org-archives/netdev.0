From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 6/8] Make the sk_clone() lighter
Date: Wed, 31 Oct 2007 16:54:34 +0300
Message-ID: <4728891A.30305@openvz.org>
References: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37388 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709AbXJaMwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 08:52:17 -0400
In-Reply-To: <472885B1.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sk_prot_alloc() already performs all the stuff needed by the
sk_clone(). Besides, the sk_prot_alloc() requires almost twice
less arguments than the sk_alloc() does, so call the sk_prot_alloc()
saving the stack a bit.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/sock.c b/net/core/sock.c
index e7537e4..c032f48 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -976,8 +976,9 @@ void sk_free(struct sock *sk)
 
 struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 {
-	struct sock *newsk = sk_alloc(sk->sk_net, sk->sk_family, priority, sk->sk_prot, 0);
-
+	struct sock *newsk;
+
+	newsk = sk_prot_alloc(sk->sk_prot, priority, sk->sk_family);
 	if (newsk != NULL) {
 		struct sk_filter *filter;
 
-- 
1.5.3.4

