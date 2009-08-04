From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 2/2] net: implement a SO_DOMAIN getsockoption
Date: Tue,  4 Aug 2009 19:28:29 +0200
Message-ID: <1249406909-24161-2-git-send-email-jengelh@medozas.de>
References: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:53440 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932928AbZHDR2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 13:28:30 -0400
In-Reply-To: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sockopt goes in line with SO_TYPE and SO_PROTOCOL. It makes it
possible for userspace programs to pass around file descriptors=C2=A0=E2=
=80=94 I
am referring to arguments-to-functions, but it may even work for the
fd passing over UNIX sockets=C2=A0=E2=80=94 without needing to also pas=
s the
auxiliary information (PF_INET6/IPPROTO_TCP).

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 arch/alpha/include/asm/socket.h      |    1 +
 arch/arm/include/asm/socket.h        |    1 +
 arch/avr32/include/asm/socket.h      |    1 +
 arch/cris/include/asm/socket.h       |    1 +
 arch/frv/include/asm/socket.h        |    1 +
 arch/h8300/include/asm/socket.h      |    1 +
 arch/ia64/include/asm/socket.h       |    1 +
 arch/m32r/include/asm/socket.h       |    1 +
 arch/m68k/include/asm/socket.h       |    1 +
 arch/microblaze/include/asm/socket.h |    1 +
 arch/mips/include/asm/socket.h       |    1 +
 arch/mn10300/include/asm/socket.h    |    1 +
 arch/parisc/include/asm/socket.h     |    1 +
 arch/powerpc/include/asm/socket.h    |    1 +
 arch/s390/include/asm/socket.h       |    1 +
 arch/sparc/include/asm/socket.h      |    1 +
 arch/x86/include/asm/socket.h        |    1 +
 arch/xtensa/include/asm/socket.h     |    1 +
 include/asm-generic/socket.h         |    1 +
 net/core/sock.c                      |    5 +++++
 20 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/s=
ocket.h
index 2f8b4d3..26773e3 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -33,6 +33,7 @@
 #define	SO_SNDTIMEO	0x1013
 #define SO_ACCEPTCONN	0x1014
 #define SO_PROTOCOL	0x1028
+#define SO_DOMAIN	0x1029
=20
 /* linux-specific, might as well be the same as on i386 */
 #define SO_NO_CHECK	11
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socke=
t.h
index 7f47454..92ac61d 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/s=
ocket.h
index 6af2866..fe863f9 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/soc=
ket.h
index f3859fb..45ec49b 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -60,6 +60,7 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
=20
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socke=
t.h
index 8dab348..2dea726 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -58,6 +58,7 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
=20
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/s=
ocket.h
index ba770d0..1547f01 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/soc=
ket.h
index 091cd9d..0b0d5ff 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -67,5 +67,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/soc=
ket.h
index d36f592..3390a86 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/soc=
ket.h
index 060cb7e..eee01cc 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/microblaze/include/asm/socket.h b/arch/microblaze/inc=
lude/asm/socket.h
index 96bf8bf..7361ae7 100644
--- a/arch/microblaze/include/asm/socket.h
+++ b/arch/microblaze/include/asm/socket.h
@@ -67,5 +67,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_MICROBLAZE_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/soc=
ket.h
index 289ce5f..ae05acc 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -43,6 +43,7 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local ad=
dress and port reuse.  */
 #define SO_RCVTIMEO 	0x1006	/* receive timeout */
 #define SO_ACCEPTCONN	0x1009
 #define SO_PROTOCOL	0x1028	/* protocol type */
+#define SO_DOMAIN	0x1029	/* domain/socket family */
=20
 /* linux-specific, might as well be the same as on i386 */
 #define SO_NO_CHECK	11
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/a=
sm/socket.h
index 19d7cf7..4df75af 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm=
/socket.h
index a658b09..960b1e5 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -25,6 +25,7 @@
 #define SO_ERROR	0x1007
 #define SO_TYPE		0x1008
 #define SO_PROTOCOL	0x1028
+#define SO_DOMAIN	0x1029
 #define SO_PEERNAME	0x2000
=20
 #define SO_NO_CHECK	0x400b
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/a=
sm/socket.h
index 609049d..3ab8b3e 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -65,5 +65,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/soc=
ket.h
index 65baa9a..e42df89 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -66,5 +66,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/s=
ocket.h
index 9cbbfaf..3a5ae3d 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -30,6 +30,7 @@
 #define SO_ERROR	0x1007
 #define SO_TYPE		0x1008
 #define SO_PROTOCOL	0x1028
+#define SO_DOMAIN	0x1029
=20
=20
 /* Linux specific, keep the same. */
diff --git a/arch/x86/include/asm/socket.h b/arch/x86/include/asm/socke=
t.h
index 1077d25..b2a8c74 100644
--- a/arch/x86/include/asm/socket.h
+++ b/arch/x86/include/asm/socket.h
@@ -58,5 +58,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* _ASM_X86_SOCKET_H */
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm=
/socket.h
index e47f172..beb3a6b 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -69,5 +69,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.=
h
index 7e24d18..538991c 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -61,5 +61,6 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
=20
 #define SO_PROTOCOL		38
+#define SO_DOMAIN		39
=20
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index fb71d9e..025317f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -483,6 +483,7 @@ int sock_setsockopt(struct socket *sock, int level,=
 int optname,
 		break;
 	case SO_TYPE:
 	case SO_PROTOCOL:
+	case SO_DOMAIN:
 	case SO_ERROR:
 		ret =3D -ENOPROTOOPT;
 		break;
@@ -769,6 +770,10 @@ int sock_getsockopt(struct socket *sock, int level=
, int optname,
 		v.val =3D sk->sk_protocol;
 		break;
=20
+	case SO_DOMAIN:
+		v.val =3D sk->sk_family;
+		break;
+
 	case SO_ERROR:
 		v.val =3D -sock_error(sk);
 		if (v.val =3D=3D 0)
--=20
1.6.3.3

