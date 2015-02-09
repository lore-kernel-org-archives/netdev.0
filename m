From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next 3/3] net: Introducing socket mark receive socket option
Date: Mon,  9 Feb 2015 20:15:23 +0200
Message-ID: <1423505723-2281-4-git-send-email-eyal.birger@gmail.com>
References: <1423505723-2281-1-git-send-email-eyal.birger@gmail.com>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:63683 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933723AbbBISPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 13:15:47 -0500
Received: by mail-wi0-f180.google.com with SMTP id z2so8321577wiv.1
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 10:15:46 -0800 (PST)
In-Reply-To: <1423505723-2281-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A userspace program may wish to receive the mark of packets it receives.

Packets may be marked by Netfilter, by other userspace applications
using the SO_MARK socket option, or by other kernel means.

Receiving the mark in userspace is useful for example for distinguishing
between different TPROXY diversion rules to the same userspace proxy socket.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 arch/alpha/include/uapi/asm/socket.h   | 2 ++
 arch/avr32/include/uapi/asm/socket.h   | 2 ++
 arch/cris/include/uapi/asm/socket.h    | 2 ++
 arch/frv/include/uapi/asm/socket.h     | 2 ++
 arch/ia64/include/uapi/asm/socket.h    | 2 ++
 arch/m32r/include/uapi/asm/socket.h    | 2 ++
 arch/mips/include/uapi/asm/socket.h    | 2 ++
 arch/mn10300/include/uapi/asm/socket.h | 2 ++
 arch/parisc/include/uapi/asm/socket.h  | 2 ++
 arch/powerpc/include/uapi/asm/socket.h | 2 ++
 arch/s390/include/uapi/asm/socket.h    | 2 ++
 arch/sparc/include/uapi/asm/socket.h   | 2 ++
 arch/xtensa/include/uapi/asm/socket.h  | 2 ++
 include/net/sock.h                     | 8 +++++---
 include/uapi/asm-generic/socket.h      | 2 ++
 net/core/sock.c                        | 8 ++++++++
 net/socket.c                           | 9 +++++++++
 17 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9a20821..7c49f4b 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 2b65ed6..6c81e0e 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index e2503d9f..55ca3be 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -87,6 +87,8 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 4823ad1..b69f0d5 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -85,5 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 59be3d8..ee6abaf 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 7bc4cb2..bf0f932 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index dec3c85..47a61c4 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index cab7d6d..216305b 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index a5cd40c..047980a3 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -84,4 +84,6 @@
 #define SO_ATTACH_BPF		0x402B
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		0x402C
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index c046666..188abb6 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 296942d..70a5791 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index e6a16c4..f7ee249 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -81,6 +81,8 @@
 #define SO_ATTACH_BPF		0x0034
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		0x0035
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 4120af0..5b588fa 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 412cab78..f179dbc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -719,6 +719,7 @@ enum sock_flags {
 		     */
 	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
 	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
+	SOCK_RCVMARK,
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -2119,12 +2120,13 @@ void __sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
 static inline void sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
 					  struct sk_buff *skb)
 {
-#define FLAGS_TS_OR_DROPS ((1UL << SOCK_RXQ_OVFL)			| \
-			   (1UL << SOCK_RCVTSTAMP))
+#define FLAGS_CMSG_ANY	  ((1UL << SOCK_RXQ_OVFL)			| \
+			   (1UL << SOCK_RCVTSTAMP)			| \
+			   (1UL << SOCK_RCVMARK))
 #define TSFLAGS_ANY	  (SOF_TIMESTAMPING_SOFTWARE			| \
 			   SOF_TIMESTAMPING_RAW_HARDWARE)
 
-	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
+	if (sk->sk_flags & FLAGS_CMSG_ANY || sk->sk_tsflags & TSFLAGS_ANY)
 		__sock_cmsg_recv(msg, sk, skb);
 	else
 		sk->sk_stamp = skb->tstamp;
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 5c15c2a..17a1e2e 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -87,4 +87,6 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_RCVMARK		51
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20..36fe687 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -928,6 +928,10 @@ set_rcvbuf:
 			sk->sk_mark = val;
 		break;
 
+	case SO_RCVMARK:
+		sock_valbool_flag(sk, SOCK_RCVMARK, valbool);
+		break;
+
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
 	case SO_RXQ_OVFL:
@@ -1179,6 +1183,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_mark;
 		break;
 
+	case SO_RCVMARK:
+		v.val = sock_flag(sk, SOCK_RCVMARK);
+		break;
+
 	case SO_RXQ_OVFL:
 		v.val = sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
diff --git a/net/socket.c b/net/socket.c
index 17be338..d4a860b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -736,11 +736,20 @@ static inline void sock_recv_drops(struct msghdr *msg, struct sock *sk,
 			sizeof(__u32), &skb->dropcount);
 }
 
+static inline void sock_recv_mark(struct msghdr *msg, struct sock *sk,
+				  struct sk_buff *skb)
+{
+	if (sock_flag(sk, SOCK_RCVMARK) && skb)
+		put_cmsg(msg, SOL_SOCKET, SO_RCVMARK,
+			 sizeof(__u32), &skb->mark);
+}
+
 void __sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
 		      struct sk_buff *skb)
 {
 	sock_recv_timestamp(msg, sk, skb);
 	sock_recv_drops(msg, sk, skb);
+	sock_recv_mark(msg, sk, skb);
 }
 EXPORT_SYMBOL_GPL(__sock_cmsg_recv);
 
-- 
2.1.4
