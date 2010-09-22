From: kaber@trash.net
Subject: [PATCH 1/6] netfilter: tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Wed, 22 Sep 2010 09:17:29 +0200
Message-ID: <1285139854-11827-2-git-send-email-kaber@trash.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab0IVHRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 03:17:37 -0400
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

transparent field of a socket is either inet_twsk(sk)->tw_transparent
for timewait sockets, or inet_sk(sk)->transparent for other sockets
(TCP/UDP).

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_tproxy_core.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index 5490fc3..daab8c4 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -70,7 +70,11 @@ nf_tproxy_destructor(struct sk_buff *skb)
 int
 nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
 {
-	if (inet_sk(sk)->transparent) {
+	bool transparent = (sk->sk_state == TCP_TIME_WAIT) ?
+				inet_twsk(sk)->tw_transparent :
+				inet_sk(sk)->transparent;
+
+	if (transparent) {
 		skb_orphan(skb);
 		skb->sk = sk;
 		skb->destructor = nf_tproxy_destructor;
-- 
1.7.1

