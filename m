From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 1/3] caif: Fix compile warning
Date: Thu,  2 Feb 2012 12:19:23 +0100
Message-ID: <1328181565-13781-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41161 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753917Ab2BBLTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 06:19:34 -0500
Received: by lagu2 with SMTP id u2so1211951lag.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 03:19:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix compile warning:
=2E.. warning: statement with no effect [-Wunused-value]
This warning is seen when debug-fs is disabled. Fix this
by adding new macro for use when no return value is needed.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index a986280..543f23c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -60,11 +60,13 @@ struct debug_fs_counter {
 	atomic_t num_rx_flow_on;
 };
 static struct debug_fs_counter cnt;
-#define	dbfs_atomic_inc(v) atomic_inc_return(v)
-#define	dbfs_atomic_dec(v) atomic_dec_return(v)
+#define	dbfs_atomic_inc(v) atomic_inc(v)
+#define	dbfs_atomic_dec(v) atomic_dec(v)
+#define	dbfs_atomic_inc_ret(v) atomic_inc_return(v)
 #else
-#define	dbfs_atomic_inc(v) 0
-#define	dbfs_atomic_dec(v) 0
+#define	dbfs_atomic_inc_ret(v) 0
+#define	dbfs_atomic_inc(v)
+#define	dbfs_atomic_dec(v)
 #endif
=20
 struct caifsock {
@@ -1122,7 +1124,7 @@ static int caif_create(struct net *net, struct so=
cket *sock, int protocol,
 	cf_sk->conn_req.protocol =3D protocol;
 	/* Increase the number of sockets created. */
 	dbfs_atomic_inc(&cnt.caif_nr_socks);
-	num =3D dbfs_atomic_inc(&cnt.caif_sock_create);
+	num =3D dbfs_atomic_inc_ret(&cnt.caif_sock_create);
 #ifdef CONFIG_DEBUG_FS
 	if (!IS_ERR(debugfsdir)) {
=20
--=20
1.7.5.4
