From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] [RFC] add getsockopt(SO_RCVDROPS) to fetch soclket RX drops count
Date: Mon, 20 Jul 2009 13:48:44 +0300
Message-ID: <1248086924-19016-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:38258 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbZGTKqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 06:46:38 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KAjFE8029825
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 05:46:31 -0500
Received: from localhost.localdomain (esdhcp03592.research.nokia.com [172.21.35.92])
	by mgw-sa02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KAkLpG026067
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 13:46:22 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Several socket protocols use sk_drops, but it is only visible through
protocol-specific /proc. This adds a generic socket option to retrieve
the counter of a given socket.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 arch/alpha/include/asm/socket.h      |    2 ++
 arch/arm/include/asm/socket.h        |    2 ++
 arch/avr32/include/asm/socket.h      |    2 ++
 arch/cris/include/asm/socket.h       |    2 ++
 arch/frv/include/asm/socket.h        |    2 ++
 arch/h8300/include/asm/socket.h      |    2 ++
 arch/ia64/include/asm/socket.h       |    2 ++
 arch/m32r/include/asm/socket.h       |    2 ++
 arch/m68k/include/asm/socket.h       |    2 ++
 arch/microblaze/include/asm/socket.h |    2 ++
 arch/mips/include/asm/socket.h       |    2 ++
 arch/mn10300/include/asm/socket.h    |    2 ++
 arch/parisc/include/asm/socket.h     |    2 ++
 arch/powerpc/include/asm/socket.h    |    2 ++
 arch/s390/include/asm/socket.h       |    2 ++
 arch/sparc/include/asm/socket.h      |    2 ++
 arch/x86/include/asm/socket.h        |    2 ++
 arch/xtensa/include/asm/socket.h     |    2 ++
 include/asm-generic/socket.h         |    2 ++
 net/core/sock.c                      |    4 ++++
 20 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/s=
ocket.h
index 3641ec1..9987748 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -65,6 +65,8 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore =
we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socke=
t.h
index 537de4e..4b4cbaf 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/s=
ocket.h
index 04c8606..04463b1 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/soc=
ket.h
index d5cf740..80ab434 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -59,6 +59,8 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
=20
=20
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socke=
t.h
index 57c3d40..0040d99 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -57,5 +57,7 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
=20
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/s=
ocket.h
index 602518a..78240ad 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/soc=
ket.h
index 7454212..b5c2391 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -66,4 +66,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/soc=
ket.h
index be7ed58..81d346f 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/soc=
ket.h
index ca87f93..a0a3385 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/microblaze/include/asm/socket.h b/arch/microblaze/inc=
lude/asm/socket.h
index 8259368..7d5f523 100644
--- a/arch/microblaze/include/asm/socket.h
+++ b/arch/microblaze/include/asm/socket.h
@@ -66,4 +66,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_MICROBLAZE_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/soc=
ket.h
index 2abca17..8dbc692 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -78,6 +78,8 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local ad=
dress and port reuse.  */
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #ifdef __KERNEL__
=20
 /** sock_type - Socket types
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/a=
sm/socket.h
index fb5daf4..1474ea5 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm=
/socket.h
index 885472b..7b743f3 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -57,6 +57,8 @@
 #define SO_TIMESTAMPING		0x4020
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		0x4021
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore =
we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/a=
sm/socket.h
index 1e5cfad..e787f99 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -64,4 +64,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/soc=
ket.h
index 02330c5..0ebaea1 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -65,4 +65,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/s=
ocket.h
index 982a12f..b2e1d80 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -53,6 +53,8 @@
 #define SO_TIMESTAMPING		0x0023
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		0x0024
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/x86/include/asm/socket.h b/arch/x86/include/asm/socke=
t.h
index ca8bf2c..1875822 100644
--- a/arch/x86/include/asm/socket.h
+++ b/arch/x86/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* _ASM_X86_SOCKET_H */
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm=
/socket.h
index dd1a7a4..445cb7b 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -68,4 +68,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.=
h
index 5d79e40..778283a 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -60,4 +60,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
+#define SO_RCVDROPS		38
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 73b5af5..18dbb5f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -891,6 +891,10 @@ int sock_getsockopt(struct socket *sock, int level=
, int optname,
 		v.val =3D sk->sk_mark;
 		break;
=20
+	case SO_RCVDROPS:
+		v.val =3D atomic_read(&sk->sk_drops);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
--=20
1.6.0.4

