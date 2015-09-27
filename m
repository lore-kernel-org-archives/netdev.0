From: Tolga Ceylan <tolga.ceylan@gmail.com>
Subject: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as drain mode
Date: Sat, 26 Sep 2015 17:30:48 -0700
Message-ID: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34240 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbbI0Aay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 20:30:54 -0400
Received: by padhy16 with SMTP id hy16so139586842pad.1
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 17:30:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For applications using SO_REUSEPORT listeners, there is
no clean way to switch traffic on/off or add/remove
listeners without dropping pending connections. With this
patch, applications can turn off queueing of new connections
for a specific listener socket which enables implementation of
zero down time server applications.

For example, a popular web server nginx handles application
configuration changes by forking new processes (listeners)
and waiting for old processes (listeners) to finish up their
processing. However, this approach is distruptive as removal
of a listener will drop pending connections for that listener.
Instead, with this patch, nginx can maintain two sets of listener
socket pools to be used by old/new processes and switch traffic off/on
using this socket option. Old processes set set this socket option
to drain their existing queues.

Tested on a x86_64 kernel.

Signed-off-by: Tolga Ceylan <tolga.ceylan@gmail.com>
---
 arch/alpha/include/uapi/asm/socket.h   | 2 ++
 arch/avr32/include/uapi/asm/socket.h   | 2 ++
 arch/frv/include/uapi/asm/socket.h     | 2 ++
 arch/ia64/include/uapi/asm/socket.h    | 2 ++
 arch/m32r/include/uapi/asm/socket.h    | 2 ++
 arch/mips/include/uapi/asm/socket.h    | 2 ++
 arch/mn10300/include/uapi/asm/socket.h | 2 ++
 arch/parisc/include/uapi/asm/socket.h  | 2 ++
 arch/powerpc/include/uapi/asm/socket.h | 2 ++
 arch/sparc/include/uapi/asm/socket.h   | 2 ++
 include/net/sock.h                     | 3 +++
 include/uapi/asm-generic/socket.h      | 2 ++
 net/core/sock.c                        | 3 +++
 net/ipv4/inet_hashtables.c             | 5 ++++-
 14 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9a20821..d2ad268 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 2b65ed6..6b6d0af 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 4823ad1..23d6b82 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -85,5 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 59be3d8..c3d5ada 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 7bc4cb2..602f4b4 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index dec3c85..e0880e2 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index cab7d6d..d60f747 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index a5cd40c..0ffa8de 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -84,4 +84,6 @@
 #define SO_ATTACH_BPF		0x402B
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index c046666..6935839 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index e6a16c4..e5ecf16 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -81,6 +81,8 @@
 #define SO_ATTACH_BPF		0x0034
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 0x0035
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/include/net/sock.h b/include/net/sock.h
index 94dff7f..ebb3c08 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -142,6 +142,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
  *	@skc_reuseport: %SO_REUSEPORT setting
+ *	@skc_reuseport_listen_off: %SO_REUSEPORT_LISTEN_OFF setting
  *	@skc_bound_dev_if: bound device index if != 0
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
@@ -183,6 +184,7 @@ struct sock_common {
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse:4;
 	unsigned char		skc_reuseport:1;
+	unsigned char       skc_reuseport_listen_off:1;
 	unsigned char		skc_ipv6only:1;
 	unsigned char		skc_net_refcnt:1;
 	int			skc_bound_dev_if;
@@ -322,6 +324,7 @@ struct sock {
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_reuseport		__sk_common.skc_reuseport
+#define sk_reuseport_listen_off		__sk_common.skc_reuseport_listen_off
 #define sk_ipv6only		__sk_common.skc_ipv6only
 #define sk_net_refcnt		__sk_common.skc_net_refcnt
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 5c15c2a..ed22ee4 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -87,4 +87,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_REUSEPORT_LISTEN_OFF 51
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 3307c02..5861513 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -714,6 +714,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_REUSEPORT:
 		sk->sk_reuseport = valbool;
 		break;
+	case SO_REUSEPORT_LISTEN_OFF:
+		sk->sk_reuseport_listen_off = valbool;
+		break;
 	case SO_TYPE:
 	case SO_PROTOCOL:
 	case SO_DOMAIN:
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 8912019..59e8540 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -224,10 +224,13 @@ begin:
 				phash = inet_ehashfn(net, daddr, hnum,
 						     saddr, sport);
 				matches = 1;
+				if (sk->sk_reuseport_listen_off)
+					result = NULL;
 			}
 		} else if (score == hiscore && reuseport) {
 			matches++;
-			if (reciprocal_scale(phash, matches) == 0)
+			if (reciprocal_scale(phash, matches) == 0 &&
+			    !sk->sk_reuseport_listen_off)
 				result = sk;
 			phash = next_pseudo_random32(phash);
 		}
-- 
2.5.3
