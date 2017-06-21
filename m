From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v3 04/13] sock: add SOCK_ZEROCOPY sockopt
Date: Wed, 21 Jun 2017 17:18:07 -0400
Message-ID: <20170621211816.53837-5-willemdebruijn.kernel@gmail.com>
References: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35603 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751265AbdFUVS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 17:18:27 -0400
In-Reply-To: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
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
index 7b285dd4fe05..c6133a045352 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -109,4 +109,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index f1e3b20dce9f..9abf02d6855a 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -102,5 +102,7 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 5dd5c5d0d642..002eb85a6941 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -111,4 +111,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index f8f7b47e247f..e268e51a38d1 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -102,4 +102,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 882823bec153..6c755bc07975 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -120,4 +120,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index c710db354ff2..ac82a3f26dbf 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -102,4 +102,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index a0d4dc9f4eb2..3b2bf7ae703b 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SO_PEERGROUPS		0x4034
 
+#define SO_ZEROCOPY		0x4035
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 52a63f4175cb..a56916c83565 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -108,4 +108,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 186fd8199f54..b2f5c50d0947 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -98,6 +98,8 @@
 
 #define SO_PEERGROUPS		0x003d
 
+#define SO_ZEROCOPY		0x003e
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 3eed2761c149..220059999e74 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -113,4 +113,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 9861be8da65e..e47c9e436221 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -104,4 +104,6 @@
 
 #define SO_PEERGROUPS		59
 
+#define SO_ZEROCOPY		60
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
index 2822d30f2ad2..14f317d9a2bb 100644
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
@@ -1383,6 +1393,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
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
