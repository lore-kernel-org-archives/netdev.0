From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 5/5] net/sock: add support of SO_NETNS
Date: Wed, 12 Dec 2012 18:24:41 +0100
Message-ID: <1355333081-4018-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1355333081-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, aatteka@nicira.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39164 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab2LLR0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:26:34 -0500
In-Reply-To: <1355333081-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new setsockopt() option allows user to change netns of a socket. It
should be done enough early, before any bind(), etc.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/alpha/include/asm/socket.h        |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/h8300/include/asm/socket.h        |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/asm/socket.h         |  2 ++
 arch/m68k/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        | 28 ++++++++++++++++++++++++++++
 16 files changed, 58 insertions(+)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index 0087d05..13aa509 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -77,6 +77,8 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #ifdef __KERNEL__
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 486df68..39cc927 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 871f89b..ac7eef6 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -70,5 +70,7 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index 90a2e57..4d2a4e8 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 23d6759..ed4534b 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/socket.h
index 5e7088a..37d0eb0 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/uapi/asm/socket.h b/arch/m68k/include/uapi/asm/socket.h
index 285da3b..e79aad8 100644
--- a/arch/m68k/include/uapi/asm/socket.h
+++ b/arch/m68k/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 17307ab..356f943 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -90,5 +90,7 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index af5366b..b899cf8 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index d9ff473..8503329 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -69,6 +69,8 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		0x4024
 
+#define SO_NETNS		0x4025
+
 
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index eb0b186..1a520ff 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -77,4 +77,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 436d07c..cbdda59 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -76,4 +76,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index c83a937..c1c2853 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -66,6 +66,8 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		0x0027
 
+#define SO_NETNS		0x0028
+
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 38079be..a8f956d 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -81,4 +81,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2d32d07..08c108c 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -73,4 +73,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_NETNS		44
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index a692ef4..7ec288f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -895,6 +895,30 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_NOFCS, valbool);
 		break;
 
+	case SO_NETNS:
+#ifdef CONFIG_NET_NS
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+			ret = -EPERM;
+		else if (sk->sk_state != TCP_CLOSE)
+			ret = -EBUSY;	/* Too late to change netns */
+		else {
+			struct net *net = get_net_ns_by_nsindex(val);
+
+			if (net) {
+				/* We can not use sk_change_net() because sk
+				 * will not be released with
+				 * sk_release_kernel(). Let do it manually.
+				 */
+				put_net(sock_net(sk));
+				sock_net_set(sk, net);
+			} else
+				ret = -EINVAL;
+		}
+#else
+		ret = -EOPNOTSUPP;
+#endif
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1140,6 +1164,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 		goto lenout;
 
+	case SO_NETNS:
+		v.val = sock_net(sk)->nsindex;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.8.0.1
