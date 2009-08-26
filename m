From: Clement LECIGNE <clement.lecigne@netasq.com>
Subject: [PATCH] 8 bytes kernel memory disclosure in AppleTalk getsockname.
Date: Wed, 26 Aug 2009 13:12:47 +0200
Message-ID: <20090826111247.GA79673@clem1.netasq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932286AbZHZLfY@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In function atalk_getname(), sockaddr_at is returned in userland withou=
t
zero'ing the "char sat_zero[8]" field. This bug allows user to display =
8
bytes leaked from the kernel stack.

Here is a patch that zero the whole sockaddr_at structure before
processing it. It should fix this bug.

Signed-off-by: Cl=E9ment Lecigne <clement.lecigne@netasq.com>
--- linux/net/appletalk/ddp.c	2009-08-26 11:35:59.000000000 +0200
+++ linux/net/appletalk/ddp.c	2009-08-26 11:36:30.000000000 +0200
@@ -1241,6 +1241,8 @@ static int atalk_getname(struct socket *
 		if (atalk_autobind(sk) < 0)
 			return -ENOBUFS;
=20
+	memset(&sat, 0, sizeof(struct sockaddr_at));
+
 	*uaddr_len =3D sizeof(struct sockaddr_at);
=20
 	if (peer) {

--=20
Cl=E9ment LECIGNE,
-Only one remote hole in the default install, in more than 10 years!<br=
>
+Only two remote holes in the default install, in more than 10 years!<b=
r>
