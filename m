From: Chris Kuiper <ckuiper@google.com>
Subject: [PATCH] net: udp: add socket option to report RX queue level
Date: Fri, 17 Mar 2017 14:13:12 -0700
Message-ID: <20170317211312.38117-1-ckuiper@google.com>
Cc: pgynther@google.com, Chris Kuiper <ckuiper@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33692 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdCQVPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 17:15:10 -0400
Received: by mail-pg0-f42.google.com with SMTP id n190so48925385pga.0
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 14:13:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new socket option "SO_RXQ_ALLOC" that enables providing
the RX queue buffer allocation as ancillary data from the recvmsg()
system call. The value reported is a byte number and together with
the RX queue size (obtained via getsockopt(SO_RCVBUF) can be used to
calculate a percentage value on how full the socket buffer is.
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  3 ++-
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/net/sock.h                     |  9 +++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        |  8 ++++++++
 net/ipv4/udp.c                         |  1 +
 net/ipv6/udp.c                         |  1 +
 net/socket.c                           | 12 ++++++++++++
 18 files changed, 57 insertions(+), 1 deletion(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index afc901b7a6f6..f6e945dccdc7 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 5a650426f357..b1023265a58e 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 81e03530ed39..136b6eb01801 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -92,5 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
-#endif /* _ASM_SOCKET_H */
+#define SO_RXQ_ALLOC		55
 
+#endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 57feb0c1f7d7..b0b39ef019cf 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5853f8e92c20..f70966ea464e 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 566ecdcb5b4b..03932e896273 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -110,4 +110,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 0e12527c4b0e..d7b8dc2f454b 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 7a109b73ddf7..9062b32b828d 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	0x402F
 
+#define SO_RXQ_ALLOC		0x4030
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 44583a52f882..6971a55b3b2f 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index b24a64cbfeb1..30c7b63e3ed6 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index a25dc32f5d6a..f1d1fb318be0 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -88,6 +88,8 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	0x0038
 
+#define SO_RXQ_ALLOC		0x0039
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 9fdbe1fe0473..e9637dd7c5a6 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 08142be8938e..6297d65078bf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -758,6 +758,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_RX_SOFTWARE,  /* %SOF_TIMESTAMPING_RX_SOFTWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_RXQ_ALLOC,
 	SOCK_ZEROCOPY, /* buffers from userspace */
 	SOCK_WIFI_STATUS, /* push wifi status to userspace */
 	SOCK_NOFCS, /* Tell NIC not to do the Ethernet FCS.
@@ -2253,6 +2254,14 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 		sk->sk_stamp = skb->tstamp;
 }
 
+void __sock_recv_alloc(struct msghdr *msg, struct sock *sk);
+
+static inline void sock_recv_alloc(struct msghdr *msg, struct sock *sk)
+{
+	if (sock_flag(sk, SOCK_RXQ_ALLOC))
+		__sock_recv_alloc(msg, sk);
+}
+
 void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags);
 
 /**
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2c748ddad5f8..b0f569ceca03 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -94,4 +94,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_RXQ_ALLOC		55
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index a83731c36761..486d462349fb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1006,6 +1006,10 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		sock_valbool_flag(sk, SOCK_RXQ_OVFL, valbool);
 		break;
 
+	case SO_RXQ_ALLOC:
+		sock_valbool_flag(sk, SOCK_RXQ_ALLOC, valbool);
+		break;
+
 	case SO_WIFI_STATUS:
 		sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
 		break;
@@ -1263,6 +1267,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
+	case SO_RXQ_ALLOC:
+		v.val = sock_flag(sk, SOCK_RXQ_ALLOC);
+		break;
+
 	case SO_WIFI_STATUS:
 		v.val = sock_flag(sk, SOCK_WIFI_STATUS);
 		break;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ea6e4cff9faf..0adf2d3840f1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1470,6 +1470,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 			      UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_recv_alloc(msg, sk);
 
 	/* Copy the address. */
 	if (sin) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 08a188ffe070..c95bbd65444f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -413,6 +413,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	}
 
 	sock_recv_ts_and_drops(msg, sk, skb);
+	sock_recv_alloc(msg, sk);
 
 	/* Copy the address. */
 	if (msg->msg_name) {
diff --git a/net/socket.c b/net/socket.c
index e034fe4164be..13ee85e4c634 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -734,6 +734,18 @@ void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
 
+void __sock_recv_alloc(struct msghdr *msg, struct sock *sk)
+{
+	__u32 rmem_alloc;
+
+	if (sock_flag(sk, SOCK_RXQ_ALLOC)) {
+		rmem_alloc = atomic_read(&sk->sk_rmem_alloc);
+		put_cmsg(msg, SOL_SOCKET, SO_RXQ_ALLOC,
+				sizeof(rmem_alloc), &rmem_alloc);
+	}
+}
+EXPORT_SYMBOL_GPL(__sock_recv_alloc);
+
 static inline int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 				     int flags)
 {
-- 
2.12.0.367.g23dc2f6d3c-goog
