From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] l2tp: fix unused variable warning
Date: Fri, 07 Mar 2014 14:57:43 -0800
Message-ID: <1394233063.20149.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:44293 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbaCGW5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 17:57:45 -0500
Received: by mail-pb0-f51.google.com with SMTP id uo5so4750778pbc.24
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 14:57:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net/l2tp/l2tp_core.c:1111:15: warning: unused variable
'sk' [-Wunused-variable]

Fixes: 31c70d5956fc ("l2tp: keep original skb ownership")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/l2tp/l2tp_core.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 9958c31c2c54..dcab9ddc4388 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1108,7 +1108,6 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 			  struct flowi *fl, size_t data_len)
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
-	struct sock *sk = tunnel->sock;
 	unsigned int len = skb->len;
 	int error;
 
@@ -1132,7 +1131,7 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	/* Queue the packet to IP for output */
 	skb->local_df = 1;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (sk->sk_family == PF_INET6 && !tunnel->v4mapped)
+	if (tunnel->sock->sk_family == PF_INET6 && !tunnel->v4mapped)
 		error = inet6_csk_xmit(skb, NULL);
 	else
 #endif
