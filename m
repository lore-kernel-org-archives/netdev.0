From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: sctp should update its inuse counter
Date: Mon, 17 Nov 2008 11:39:50 +0100
Message-ID: <492149F6.5060805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000108060409010106010505"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:49026 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbYKQKkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:40:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000108060409010106010505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch is a preparation to namespace conversion of /proc/net/protocols

In order to have relevant information for SCTP protocols, we should use
sock_prot_inuse_add() to update a (percpu and pernamespace) counter of
inuse sockets.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/sctp/socket.c |    2 ++
 1 files changed, 2 insertions(+)

--------------000108060409010106010505
Content-Type: text/plain;
 name="sctp_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sctp_inuse.patch"

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a1b9045..0c70eff 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3614,6 +3614,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 
 	SCTP_DBG_OBJCNT_INC(sock);
 	atomic_inc(&sctp_sockets_allocated);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	return 0;
 }
 
@@ -3628,6 +3629,7 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
 	atomic_dec(&sctp_sockets_allocated);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 }
 
 /* API 4.1.7 shutdown() - TCP Style Syntax

--------------000108060409010106010505--
