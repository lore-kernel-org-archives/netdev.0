From: Olaf Hering <olh@suse.de>
Subject: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check missing
Date: Sat, 5 Jun 2004 22:43:34 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040605204334.GA1134@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S261913AbUFEUnh@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


packet_recvmsg() gets the flags from the compat_sys_socketcall(), but i=
t
does not check for the active MSG_CMSG_COMPAT bit. As a result, it
returns -EINVAL and makes the user rather unhappy


diff -purN linux-2.6.7-rc2-bk5.orig/net/packet/af_packet.c linux-2.6.7-=
rc2-bk5/net/packet/af_packet.c
--- linux-2.6.7-rc2-bk5.orig/net/packet/af_packet.c	2004-06-05 09:34:48=
=2E000000000 +0200
+++ linux-2.6.7-rc2-bk5/net/packet/af_packet.c	2004-06-05 22:32:16.0000=
00000 +0200
@@ -1037,7 +1037,7 @@ static int packet_recvmsg(struct kiocb *
 	int copied, err;
=20
 	err =3D -EINVAL;
-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC))
+	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
 		goto out;
=20
 #if 0
--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
