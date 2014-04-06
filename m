From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] tipc: Let tipc_release() return 0
Date: Sun,  6 Apr 2014 15:56:14 +0200
Message-ID: <1396792574-32169-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/tipc/socket.c: In function =E2=80=98tipc_release=E2=80=99:
net/tipc/socket.c:352: warning: =E2=80=98res=E2=80=99 is used uninitial=
ized in this function

Introduced by commit 24be34b5a0c9114541891d29dff1152bb1a8df34 ("tipc:
eliminate upcall function pointers between port and socket"), which
removed the sole initializer of "res".

Just return 0 to fix it.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/tipc/socket.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 29b7f26a12cf..adc12e227303 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -301,7 +301,6 @@ static int tipc_release(struct socket *sock)
 	struct tipc_sock *tsk;
 	struct tipc_port *port;
 	struct sk_buff *buf;
-	int res;
=20
 	/*
 	 * Exit if socket isn't fully initialized (occurs when a failed accep=
t()
@@ -349,7 +348,7 @@ static int tipc_release(struct socket *sock)
 	sock_put(sk);
 	sock->sk =3D NULL;
=20
-	return res;
+	return 0;
 }
=20
 /**
--=20
1.7.9.5
