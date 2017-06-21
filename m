From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 04/13] sock: add SOCK_ZEROCOPY sockopt
Date: Wed, 21 Jun 2017 16:36:43 -0400
Message-ID: <20170621203652.15306-5-willemdebruijn.kernel@gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34586 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdFUUhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:37:00 -0400
In-Reply-To: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The send call ignores unknown flags. Legacy applications may already
unwittingly pass MSG_ZEROCOPY. Continue to ignore this flag unless a
socket opts in to zerocopy.

Introduce socket option SO_ZEROCOPY to enable MSG_ZEROCOPY processing.
Processes can also query this socket option to detect kernel support
for the feature. Older kernels will return ENOPROTOOPT.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/skbuff.c                      |  3 +++
 net/core/sock.c                        | 14 ++++++++++++++
 13 files changed, 39 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 0926de63a62b..baa974af3bf5 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -107,4 +107,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index e491ff08b9a9..2946772c7cc9 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -100,5 +100,7 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 869372413333..f1bdc5220254 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -109,4 +109,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5d97890a8704..f9573e69d5dd 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -100,4 +100,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 365ff51f033a..d8c67fbd0f3d 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -118,4 +118,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index d013c0da0256..8fc7eb3e1a7a 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -100,4 +100,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index b893ca14fade..8dcdaaa80c51 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	0x4033
 
+#define SO_ZEROCOPY		0x4034
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index fb9769d7e74e..32b1a8496cc3 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -106,4 +106,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 5d673302fd41..7625632a3120 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -96,6 +96,8 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	0x003c
 
+#define SO_ZEROCOPY		0x003d
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 982c2533f912..6c44060a3924 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -111,4 +111,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index a5f6e819fafd..2c5adee35bac 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -102,4 +102,6 @@
 
 #define SCM_TIMESTAMPING_PKTINFO	58
 
+#define SO_ZEROCOPY		59
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 31e31185c557..34fa1f2b7ff2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -948,6 +948,9 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 
 	WARN_ON_ONCE(!in_task());
 
+	if (!sock_flag(sk, SOCK_ZEROCOPY))
+		return NULL;
+
 	skb = sock_omalloc(sk, 0, GFP_KERNEL);
 	if (!skb)
 		return NULL;
diff --git a/net/core/sock.c b/net/core/sock.c
index d1309d6f9f3d..72f5f256c2bc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1055,6 +1055,16 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		if (val == 1)
 			dst_negative_advice(sk);
 		break;
+
+	case SO_ZEROCOPY:
+		if (sk->sk_state != TCP_CLOSE)
+			ret = -EBUSY;
+		else if (val < 0 || val > 1)
+			ret = -EINVAL;
+		else
+			sock_valbool_flag(sk, SOCK_ZEROCOPY, valbool);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1350,6 +1360,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val64 = sock_gen_cookie(sk);
 		break;
 
+	case SO_ZEROCOPY:
+		v.val = sock_flag(sk, SOCK_ZEROCOPY);
+		break;
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
-- 
2.13.1.611.g7e3b11ae1-goog
