From: Richard Cochran <rcochran@linutronix.de>
Subject: [PATCH RFC V1 net-next 1/6] net: Add a new socket option for a future transmit time.
Date: Mon, 18 Sep 2017 09:41:16 +0200
Message-ID: <ad6e265b97b66bcdb19b815e6d9092ffbcb461ba.1505719061.git.rcochran@linutronix.de>
References: <cover.1505719061.git.rcochran@linutronix.de>
Cc: <linux-kernel@vger.kernel.org>, intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:49781 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752480AbdIRHnW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 03:43:22 -0400
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces SO_TXTIME.  User space enables this option in
order to pass a desired future transmit time in a CMSG when calling
sendmsg(2).

Signed-off-by: Richard Cochran <rcochran@linutronix.de>
---
 arch/alpha/include/uapi/asm/socket.h   |  3 +++
 arch/frv/include/uapi/asm/socket.h     |  3 +++
 arch/ia64/include/uapi/asm/socket.h    |  3 +++
 arch/m32r/include/uapi/asm/socket.h    |  3 +++
 arch/mips/include/uapi/asm/socket.h    |  3 +++
 arch/mn10300/include/uapi/asm/socket.h |  3 +++
 arch/parisc/include/uapi/asm/socket.h  |  3 +++
 arch/powerpc/include/uapi/asm/socket.h |  3 +++
 arch/s390/include/uapi/asm/socket.h    |  3 +++
 arch/sparc/include/uapi/asm/socket.h   |  3 +++
 arch/xtensa/include/uapi/asm/socket.h  |  3 +++
 include/net/sock.h                     |  2 ++
 include/uapi/asm-generic/socket.h      |  3 +++
 net/core/sock.c                        | 12 ++++++++++++
 14 files changed, 50 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index c6133a045352..4dfacba7820e 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -111,4 +111,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 9abf02d6855a..ccf79fe9f35a 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -104,5 +104,8 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 002eb85a6941..2da305fa85ee 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -113,4 +113,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index e268e51a38d1..4d4cde60c520 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -104,4 +104,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 6c755bc07975..b6e13bbf970c 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -122,4 +122,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index ac82a3f26dbf..0234496dc969 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -104,4 +104,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 3b2bf7ae703b..e2a282fefcd6 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -103,4 +103,7 @@
 
 #define SO_ZEROCOPY		0x4035
 
+#define SO_TXTIME		0x4036
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 3c590c7c42c0..55718129ab06 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -17,4 +17,7 @@
 
 #include <asm-generic/socket.h>
 
+#define SO_TXTIME		54
+#define SCM_TXTIME		SO_TXTIME
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index a56916c83565..bfcb29ccf33a 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -110,4 +110,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index b2f5c50d0947..2217187f80f2 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -100,6 +100,9 @@
 
 #define SO_ZEROCOPY		0x003e
 
+#define SO_TXTIME		0x003f
+#define SCM_TXTIME		SO_TXTIME
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 220059999e74..36bdbd8bd6ca 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -115,4 +115,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 03a362568357..1c378db1060f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -778,6 +778,7 @@ enum sock_flags {
 	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
 	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
 	SOCK_RCU_FREE, /* wait rcu grace period in sk_destruct() */
+	SOCK_TXTIME,
 };
 
 #define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
@@ -1558,6 +1559,7 @@ void sock_kzfree_s(struct sock *sk, void *mem, int size);
 void sk_send_sigurg(struct sock *sk);
 
 struct sockcm_cookie {
+	u64 transmit_time;
 	u32 mark;
 	u16 tsflags;
 };
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index e47c9e436221..d32e3e1bf4b6 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -106,4 +106,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_TXTIME		61
+#define SCM_TXTIME		SO_TXTIME
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 9b7b6bbb2a23..d916a4c238dd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1059,6 +1059,13 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 			sock_valbool_flag(sk, SOCK_ZEROCOPY, valbool);
 		break;
 
+	case SO_TXTIME:
+		if (ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+			sock_valbool_flag(sk, SOCK_TXTIME, valbool);
+		else
+			ret = -EPERM;
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -2115,6 +2122,11 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 		sockc->tsflags &= ~SOF_TIMESTAMPING_TX_RECORD_MASK;
 		sockc->tsflags |= tsflags;
 		break;
+	case SO_TXTIME:
+		if (!sock_flag(sk, SOCK_TXTIME))
+			return -EINVAL;
+		sockc->transmit_time = *(u64 *)CMSG_DATA(cmsg);
+		break;
 	/* SCM_RIGHTS and SCM_CREDENTIALS are semantically in SOL_UNIX. */
 	case SCM_RIGHTS:
 	case SCM_CREDENTIALS:
-- 
2.11.0
