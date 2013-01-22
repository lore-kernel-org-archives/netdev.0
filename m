From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/5] soreuseport: infrastructure
Date: Tue, 22 Jan 2013 11:49:50 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301221141100.26241@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:40357 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab3AVTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:49:51 -0500
Received: by mail-qc0-f202.google.com with SMTP id s25so215168qcq.5
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 11:49:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Definitions and macros for implementing soreusport.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   |    2 +-
 arch/avr32/include/uapi/asm/socket.h   |    2 +-
 arch/cris/include/uapi/asm/socket.h    |    2 +-
 arch/frv/include/uapi/asm/socket.h     |    2 +-
 arch/h8300/include/uapi/asm/socket.h   |    2 +-
 arch/ia64/include/uapi/asm/socket.h    |    2 +-
 arch/m32r/include/uapi/asm/socket.h    |    2 +-
 arch/mips/include/uapi/asm/socket.h    |    3 +--
 arch/mn10300/include/uapi/asm/socket.h |    2 +-
 arch/parisc/include/uapi/asm/socket.h  |    2 +-
 arch/powerpc/include/uapi/asm/socket.h |    2 +-
 arch/s390/include/uapi/asm/socket.h    |    2 +-
 arch/sparc/include/uapi/asm/socket.h   |    2 +-
 arch/xtensa/include/uapi/asm/socket.h  |    2 +-
 include/linux/random.h                 |    6 ++++++
 include/net/sock.h                     |    5 ++++-
 include/uapi/asm-generic/socket.h      |    3 +--
 net/core/sock.c                        |    7 +++++++
 18 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 755702e..c519552 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -19,7 +19,7 @@
 #define SO_BROADCAST	0x0020
 #define SO_LINGER	0x0080
 #define SO_OOBINLINE	0x0100
-/* To add :#define SO_REUSEPORT 0x0200 */
+#define SO_REUSEPORT	0x0200
 
 #define SO_TYPE		0x1008
 #define SO_ERROR	0x1007
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index f3f38a0..51c6401 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -22,7 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index 406b583..50692b7 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -24,7 +24,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index d8e1132..595391f 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -22,7 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
index c8b87a8..43e3262 100644
--- a/arch/h8300/include/uapi/asm/socket.h
+++ b/arch/h8300/include/uapi/asm/socket.h
@@ -22,7 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index f390896..c567adc 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -31,7 +31,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6a89515..519afa2 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -22,7 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 9d11a77..7e27236 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -28,8 +28,7 @@
 #define SO_LINGER	0x0080	/* Block on close of a reliable
 				   socket to transmit pending data.  */
 #define SO_OOBINLINE 0x0100	/* Receive out-of-band data in-band.  */
-#if 0
-To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
+#define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 #endif
 
 #define SO_TYPE		0x1008	/* Compatible name for SO_STYLE.  */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index ab702c4..5c7c7c9 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -22,7 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index da2c8d3..526e4b9 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -13,7 +13,7 @@
 #define SO_BROADCAST	0x0020
 #define SO_LINGER	0x0080
 #define SO_OOBINLINE	0x0100
-/* To add :#define SO_REUSEPORT 0x0200 */
+#define SO_REUSEPORT	0x0200
 #define SO_SNDBUF	0x1001
 #define SO_RCVBUF	0x1002
 #define SO_SNDBUFFORCE	0x100a
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index e6ca318..a26dcae 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -29,7 +29,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_RCVLOWAT	16
 #define SO_SNDLOWAT	17
 #define SO_RCVTIMEO	18
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 9ce60b6..f99eea7 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -28,7 +28,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index fbbba57..cbbad74 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -15,7 +15,7 @@
 #define SO_PEERCRED	0x0040
 #define SO_LINGER	0x0080
 #define SO_OOBINLINE	0x0100
-/* To add :#define SO_REUSEPORT 0x0200 */
+#define SO_REUSEPORT	0x0200
 #define SO_BSDCOMPAT    0x0400
 #define SO_RCVLOWAT     0x0800
 #define SO_SNDLOWAT     0x1000
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index dbf3164..35905cb 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -32,7 +32,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
+#define SO_REUSEPORT	15
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
 #define SO_RCVLOWAT	18
diff --git a/include/linux/random.h b/include/linux/random.h
index d984608..347ce55 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -74,4 +74,10 @@ static inline int arch_get_random_int(unsigned int *v)
 }
 #endif
 
+/* Pseudo random number generator from numerical recipes. */
+static inline u32 next_pseudo_random32(u32 seed)
+{
+	return seed * 1664525 + 1013904223;
+}
+
 #endif /* _LINUX_RANDOM_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 5a34e2f..581dc6b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -140,6 +140,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
+ *	@skc_reuseport: %SO_REUSEPORT setting
  *	@skc_bound_dev_if: bound device index if != 0
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
@@ -179,7 +180,8 @@ struct sock_common {
 
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
-	unsigned char		skc_reuse;
+	unsigned char		skc_reuse:4;
+	unsigned char		skc_reuseport:4;
 	int			skc_bound_dev_if;
 	union {
 		struct hlist_node	skc_bind_node;
@@ -297,6 +299,7 @@ struct sock {
 #define sk_family		__sk_common.skc_family
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
+#define sk_reuseport		__sk_common.skc_reuseport
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 3f6a992..4ef3acb 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -22,8 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
-
+#define SO_REUSEPORT	15
 #ifndef SO_PASSCRED /* powerpc only differs in these */
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
diff --git a/net/core/sock.c b/net/core/sock.c
index 8258fb7..235fb89 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -665,6 +665,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_REUSEADDR:
 		sk->sk_reuse = (valbool ? SK_CAN_REUSE : SK_NO_REUSE);
 		break;
+	case SO_REUSEPORT:
+		sk->sk_reuseport = valbool;
+		break;
 	case SO_TYPE:
 	case SO_PROTOCOL:
 	case SO_DOMAIN:
@@ -972,6 +975,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_reuse;
 		break;
 
+	case SO_REUSEPORT:
+		v.val = sk->sk_reuseport;
+		break;
+
 	case SO_KEEPALIVE:
 		v.val = sock_flag(sk, SOCK_KEEPOPEN);
 		break;
-- 
1.7.7.3
