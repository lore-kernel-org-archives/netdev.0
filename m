From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [Patch] Remove unnecessary check in net/sunrpc/svcsock.c
Date: Wed, 27 Sep 2006 17:34:49 +0200
Message-ID: <1159371290.9125.6.camel@alice>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:64658 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S964948AbWI0Pew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:34:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

coverity spotted this one as possible dereference in the dprintk(),
but since there is only one caller of svc_create_socket(), which always
passes a valid sin, we dont need this check.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.18-git7/net/sunrpc/svcsock.c.orig	2006-09-27 16:06:53.000000000 +0200
+++ linux-2.6.18-git7/net/sunrpc/svcsock.c	2006-09-27 16:07:09.000000000 +0200
@@ -1393,14 +1393,12 @@ svc_create_socket(struct svc_serv *serv,
 	if ((error = sock_create_kern(PF_INET, type, protocol, &sock)) < 0)
 		return error;
 
-	if (sin != NULL) {
-		if (type == SOCK_STREAM)
-			sock->sk->sk_reuse = 1; /* allow address reuse */
-		error = kernel_bind(sock, (struct sockaddr *) sin,
-						sizeof(*sin));
-		if (error < 0)
-			goto bummer;
-	}
+	if (type == SOCK_STREAM)
+		sock->sk->sk_reuse = 1; /* allow address reuse */
+	error = kernel_bind(sock, (struct sockaddr *) sin,
+					sizeof(*sin));
+	if (error < 0)
+		goto bummer;
 
 	if (protocol == IPPROTO_TCP) {
 		if ((error = kernel_listen(sock, 64)) < 0)


