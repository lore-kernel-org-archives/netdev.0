From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/8] Auto-zero the allocated sock object
Date: Wed, 31 Oct 2007 16:48:59 +0300
Message-ID: <472887CB.9050203@openvz.org>
References: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50534 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755158AbXJaMqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 08:46:42 -0400
In-Reply-To: <472885B1.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have a __GFP_ZERO flag that allocates a zeroed chunk of memory.
Use it in the sk_alloc() and avoid a hand-made memset().

This is a temporary patch that will help us in the nearest future :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/sock.c b/net/core/sock.c
index 7c2e3db..21fc79b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -908,10 +908,12 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 {
 	struct sock *sk;
 
+	if (zero_it)
+		priority |= __GFP_ZERO;
+
 	sk = sk_prot_alloc(prot, priority);
 	if (sk) {
 		if (zero_it) {
-			memset(sk, 0, prot->obj_size);
 			sk->sk_family = family;
 			/*
 			 * See comment in struct sock definition to understand
-- 
1.5.3.4

