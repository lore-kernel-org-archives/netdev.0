From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 1/2] net: implement a SO_PROTOCOL getsockoption
Date: Tue,  4 Aug 2009 19:28:28 +0200
Message-ID: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:53437 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932873AbZHDR2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 13:28:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to SO_TYPE returning the socket type, SO_PROTOCOL allows to
retrieve the protocol used with a given socket.

I am not quite sure why we have that-many copies of socket.h, and why
the values are not the same on all arches either, but for where hex
numbers dominate, I use 0x1029 for SO_PROTOCOL as that seems to be
the next free unused number across a bunch of operating systems, or
so Google results make me want to believe. SO_PROTOCOL for others
just uses the next free Linux number, 38.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 arch/alpha/include/asm/socket.h      |    1 +
 arch/arm/include/asm/socket.h        |    2 ++
 arch/avr32/include/asm/socket.h      |    2 ++
 arch/cris/include/asm/socket.h       |    2 ++
 arch/frv/include/asm/socket.h        |    2 ++
 arch/h8300/include/asm/socket.h      |    2 ++
 arch/ia64/include/asm/socket.h       |    2 ++
 arch/m32r/include/asm/socket.h       |    2 ++
 arch/m68k/include/asm/socket.h       |    2 ++
 arch/microblaze/include/asm/socket.h |    2 ++
 arch/mips/include/asm/socket.h       |    1 +
 arch/mn10300/include/asm/socket.h    |    2 ++
 arch/parisc/include/asm/socket.h     |    1 +
 arch/powerpc/include/asm/socket.h    |    2 ++
 arch/s390/include/asm/socket.h       |    2 ++
 arch/sparc/include/asm/socket.h      |    2 ++
 arch/x86/include/asm/socket.h        |    2 ++
 arch/xtensa/include/asm/socket.h     |    2 ++
 include/asm-generic/socket.h         |    2 ++
 net/core/sock.c                      |    5 +++++
 20 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index 3641ec1..2f8b4d3 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -32,6 +32,7 @@
 #define	SO_RCVTIMEO	0x1012
 #define	SO_SNDTIMEO	0x1013
 #define SO_ACCEPTCONN	0x1014
+#define SO_PROTOCOL	0x1028
 
 /* linux-specific, might as well be the same as on i386 */
 #define SO_NO_CHECK	11
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index 537de4e..7f47454 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index 04c8606..6af2866 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/socket.h
index d5cf740..f3859fb 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -59,6 +59,8 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socket.h
index 57c3d40..8dab348 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -57,5 +57,7 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index 602518a..ba770d0 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index 7454212..091cd9d 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -66,4 +66,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/socket.h
index be7ed58..d36f592 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/socket.h
index ca87f93..060cb7e 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/microblaze/include/asm/socket.h b/arch/microblaze/include/asm/socket.h
index 8259368..96bf8bf 100644
--- a/arch/microblaze/include/asm/socket.h
+++ b/arch/microblaze/include/asm/socket.h
@@ -66,4 +66,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_MICROBLAZE_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index 2abca17..289ce5f 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -42,6 +42,7 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 #define SO_SNDTIMEO	0x1005	/* send timeout */
 #define SO_RCVTIMEO 	0x1006	/* receive timeout */
 #define SO_ACCEPTCONN	0x1009
+#define SO_PROTOCOL	0x1028	/* protocol type */
 
 /* linux-specific, might as well be the same as on i386 */
 #define SO_NO_CHECK	11
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/asm/socket.h
index fb5daf4..19d7cf7 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index 885472b..a658b09 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -24,6 +24,7 @@
 #define SO_RCVTIMEO	0x1006
 #define SO_ERROR	0x1007
 #define SO_TYPE		0x1008
+#define SO_PROTOCOL	0x1028
 #define SO_PEERNAME	0x2000
 
 #define SO_NO_CHECK	0x400b
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index 1e5cfad..609049d 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -64,4 +64,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index 02330c5..65baa9a 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -65,4 +65,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index 982a12f..9cbbfaf 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -29,6 +29,8 @@
 #define SO_RCVBUFFORCE	0x100b
 #define SO_ERROR	0x1007
 #define SO_TYPE		0x1008
+#define SO_PROTOCOL	0x1028
+
 
 /* Linux specific, keep the same. */
 #define SO_NO_CHECK	0x000b
diff --git a/arch/x86/include/asm/socket.h b/arch/x86/include/asm/socket.h
index ca8bf2c..1077d25 100644
--- a/arch/x86/include/asm/socket.h
+++ b/arch/x86/include/asm/socket.h
@@ -57,4 +57,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* _ASM_X86_SOCKET_H */
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm/socket.h
index dd1a7a4..e47f172 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -68,4 +68,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 5d79e40..7e24d18 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -60,4 +60,6 @@
 #define SO_TIMESTAMPING		37
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
+#define SO_PROTOCOL		38
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index b0ba569..fb71d9e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -482,6 +482,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		sk->sk_reuse = valbool;
 		break;
 	case SO_TYPE:
+	case SO_PROTOCOL:
 	case SO_ERROR:
 		ret = -ENOPROTOOPT;
 		break;
@@ -764,6 +765,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_type;
 		break;
 
+	case SO_PROTOCOL:
+		v.val = sk->sk_protocol;
+		break;
+
 	case SO_ERROR:
 		v.val = -sock_error(sk);
 		if (v.val == 0)
-- 
1.6.3.3

