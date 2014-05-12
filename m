From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/8] sunrpc: Remove sk_no_check setting
Date: Mon, 12 May 2014 09:58:08 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405120945510.31299@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:34182 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932196AbaELQ6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 12:58:09 -0400
Received: by mail-ob0-f202.google.com with SMTP id wm4so1515641obc.3
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 09:58:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting sk_no_check to UDP_CSUM_NORCV seems to have no effect.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sunrpc/xprtsock.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 25a3dcf..1dec604 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -866,8 +866,6 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	xs_restore_old_callbacks(transport, sk);
 	write_unlock_bh(&sk->sk_callback_lock);
 
-	sk->sk_no_check = 0;
-
 	trace_rpc_socket_close(&transport->xprt, sock);
 	sock_release(sock);
 }
@@ -2046,7 +2044,6 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_user_data = xprt;
 		sk->sk_data_ready = xs_udp_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
-		sk->sk_no_check = UDP_CSUM_NORCV;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		xprt_set_connected(xprt);
-- 
1.9.1.423.g4596e3a
