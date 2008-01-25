From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TIPC] Kill unused static inline (x5)
Date: Sat, 26 Jan 2008 01:02:38 +0200
Message-ID: <12013021583862-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: per.liden@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60652 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757774AbYAYXCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 18:02:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo=3D20J=3DE4rvinen?=3D <ilpo.jarvinen@helsi=
nki.fi>

All these static inlines are unused:

in_own_zone     1 (net/tipc/addr.h)
msg_dataoctet   1 (net/tipc/msg.h)
msg_direct      1 (include/net/tipc/tipc_msg.h)
msg_options     1 (include/net/tipc/tipc_msg.h)
tipc_nmap_get   1 (net/tipc/bcast.h)

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tipc/tipc_msg.h |   16 ----------------
 net/tipc/addr.h             |    5 -----
 net/tipc/bcast.h            |   13 -------------
 net/tipc/msg.h              |    5 -----
 4 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/include/net/tipc/tipc_msg.h b/include/net/tipc/tipc_msg.h
index fb42eb7..2e159a8 100644
--- a/include/net/tipc/tipc_msg.h
+++ b/include/net/tipc/tipc_msg.h
@@ -130,11 +130,6 @@ static inline u32 msg_type(struct tipc_msg *m)
 	return msg_bits(m, 1, 29, 0x7);
 }
=20
-static inline u32 msg_direct(struct tipc_msg *m)
-{
-	return (msg_type(m) =3D=3D TIPC_DIRECT_MSG);
-}
-
 static inline u32 msg_named(struct tipc_msg *m)
 {
 	return (msg_type(m) =3D=3D TIPC_NAMED_MSG);
@@ -207,17 +202,6 @@ static inline u32 msg_nameupper(struct tipc_msg *m=
)
 	return msg_word(m, 10);
 }
=20
-static inline char *msg_options(struct tipc_msg *m, u32 *len)
-{
-	u32 pos =3D msg_bits(m, 1, 16, 0x7);
-
-	if (!pos)
-		return 0;
-	pos =3D (pos * 4) + 28;
-	*len =3D msg_hdr_sz(m) - pos;
-	return (char *)&m->hdr[pos/4];
-}
-
 #endif
=20
 #endif
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index e4bd533..3ba67e6 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -57,11 +57,6 @@ static inline int in_own_cluster(u32 addr)
 	return !((addr ^ tipc_own_addr) >> 12);
 }
=20
-static inline int in_own_zone(u32 addr)
-{
-	return !((addr ^ tipc_own_addr) >> 24);
-}
-
 static inline int is_slave(u32 addr)
 {
 	return addr & 0x800;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index f910ed2..a2416fa 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -74,19 +74,6 @@ extern char tipc_bclink_name[];
=20
=20
 /**
- * nmap_get - determine if node exists in a node map
- */
-
-static inline int tipc_nmap_get(struct node_map *nm_ptr, u32 node)
-{
-	int n =3D tipc_node(node);
-	int w =3D n / WSIZE;
-	int b =3D n % WSIZE;
-
-	return nm_ptr->map[w] & (1 << b);
-}
-
-/**
  * nmap_add - add a node to a node map
  */
=20
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index ce26598..e9ef6df 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -663,11 +663,6 @@ static inline void msg_set_remote_node(struct tipc=
_msg *m, u32 a)
 	msg_set_word(m, msg_hdr_sz(m)/4, a);
 }
=20
-static inline int msg_dataoctet(struct tipc_msg *m, u32 pos)
-{
-	return(msg_data(m)[pos + 4] !=3D 0);
-}
-
 static inline void msg_set_dataoctet(struct tipc_msg *m, u32 pos)
 {
 	msg_data(m)[pos + 4] =3D 1;
--=20
1.5.2.2

