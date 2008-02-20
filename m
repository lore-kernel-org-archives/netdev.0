From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] SUNRPC: Mark buffer used for debug printks with __maybe_unused
Date: Wed, 20 Feb 2008 17:02:43 +0300
Message-ID: <47BC3303.2040101@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41377 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbYBTOCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 09:02:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are tree places, which declare the char buf[...] on the stack
to push it later into dprintk(). Since the dprintk sometimes (if the 
CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
cause gcc to produce appropriate warnings.

Mark them as __maybe_unused.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1d3e5fc..303f105 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -175,7 +175,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
 	unsigned int	flags = MSG_MORE;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	char		buf[RPC_MAX_ADDRBUFLEN] __maybe_unused;
 
 	slen = xdr->len;
 
@@ -716,7 +716,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	char		buf[RPC_MAX_ADDRBUFLEN] __maybe_unused;
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -1206,7 +1206,7 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	struct socket	*sock;
 	int		error;
 	int		type;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	char		buf[RPC_MAX_ADDRBUFLEN] __maybe_unused;
 	struct sockaddr_storage addr;
 	struct sockaddr *newsin = (struct sockaddr *)&addr;
 	int		newlen;
