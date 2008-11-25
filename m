From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()
Date: Tue, 25 Nov 2008 21:35:23 +0100
Message-ID: <492C618B.8090403@cosmosbay.com>
References: <492AE30C.70907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030307070608000405060004"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42982 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbYKYUf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 15:35:28 -0500
In-Reply-To: <492AE30C.70907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030307070608000405060004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Oh well...

[PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()

prot->destroy is not called with BH disabled. So we must add
explicit BH disable around call to sock_prot_inuse_add()
in sctp_destroy_sock()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------030307070608000405060004
Content-Type: text/plain;
 name="sctp_prot_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sctp_prot_inuse.patch"

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f03af84..ba81fe3 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3633,7 +3633,9 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
 	atomic_dec(&sctp_sockets_allocated);
+	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	local_bh_enable();
 }
 
 /* API 4.1.7 shutdown() - TCP Style Syntax

--------------030307070608000405060004--
