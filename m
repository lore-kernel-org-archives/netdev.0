From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/8] Move the sock_copy() from the header
Date: Wed, 31 Oct 2007 16:42:01 +0300
Message-ID: <47288629.3010200@openvz.org>
References: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41850 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755138AbXJaMjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 08:39:44 -0400
In-Reply-To: <472885B1.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sock_copy() call is not used outside the sock.c file,
so just move it into a sock.c

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/sock.h b/include/net/sock.h
index 43fc3fa..ecad7b4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -993,20 +993,6 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
-static inline void sock_copy(struct sock *nsk, const struct sock *osk)
-{
-#ifdef CONFIG_SECURITY_NETWORK
-	void *sptr = nsk->sk_security;
-#endif
-
-	memcpy(nsk, osk, osk->sk_prot->obj_size);
-	get_net(nsk->sk_net);
-#ifdef CONFIG_SECURITY_NETWORK
-	nsk->sk_security = sptr;
-	security_sk_clone(osk, nsk);
-#endif
-}
-
 extern int sock_i_uid(struct sock *sk);
 extern unsigned long sock_i_ino(struct sock *sk);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index bba9949..fdacf9c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -857,6 +857,20 @@ static inline void sock_lock_init(struct sock *sk)
 			af_family_keys + sk->sk_family);
 }
 
+static void sock_copy(struct sock *nsk, const struct sock *osk)
+{
+#ifdef CONFIG_SECURITY_NETWORK
+	void *sptr = nsk->sk_security;
+#endif
+
+	memcpy(nsk, osk, osk->sk_prot->obj_size);
+	get_net(nsk->sk_net);
+#ifdef CONFIG_SECURITY_NETWORK
+	nsk->sk_security = sptr;
+	security_sk_clone(osk, nsk);
+#endif
+}
+
 /**
  *	sk_alloc - All socket objects are allocated here
  *	@net: the applicable net namespace
-- 
1.5.3.4

