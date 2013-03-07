From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] Fix: sparse warning in inet_csk_prepare_forced_close
Date: Thu,  7 Mar 2013 13:34:33 +0100
Message-ID: <1362659673-28895-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:46504 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab3CGMk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 07:40:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In e337e24d66 (inet: Fix kmemleak in tcp_v4/6_syn_recv_sock and
dccp_v4/6_request_recv_sock) I introduced the function
inet_csk_prepare_forced_close, which does a call to bh_unlock_sock().
This produces a sparse-warning.

This patch adds the missing __releases.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/inet_connection_sock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7d1874b..804c98f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -735,6 +735,7 @@ EXPORT_SYMBOL(inet_csk_destroy_sock);
  * tcp/dccp_create_openreq_child().
  */
 void inet_csk_prepare_forced_close(struct sock *sk)
+__releases(&sk->sk_lock.slock)
 {
 	/* sk_clone_lock locked the socket and set refcnt to 2 */
 	bh_unlock_sock(sk);
-- 
1.8.1.227.g44fe835
