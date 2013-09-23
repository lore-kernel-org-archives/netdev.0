From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce SO_MAX_PACING_RATE
Date: Mon, 23 Sep 2013 08:10:14 -0700
Message-ID: <1379949014.3165.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f169.google.com ([209.85.213.169]:35783 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab3IWPKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 11:10:24 -0400
Received: by mail-ye0-f169.google.com with SMTP id r13so1231174yen.0
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 08:10:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As mentioned in commit afe4fd062416b ("pkt_sched: fq: Fair Queue packet
scheduler"), this patch adds a new socket option.

SO_MAX_PACING_RATE offers the application the ability to cap the
rate computed by transport layer. Value is in bytes per second.

u32 val = 1000000;
setsockopt(sockfd, SOL_SOCKET, SO_MAX_PACING_RATE, &val, sizeof(val));

To be effectively paced, a flow must use FQ packet scheduler.

Note that a packet scheduler takes into account the headers for its
computations. The effective payload rate depends on MSS and retransmits
if any.

I chose to make this pacing rate a SOL_SOCKET option instead of a
TCP one because this can be used by other protocols.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steinar H. Gunderson <sesse@google.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
---
 arch/alpha/include/uapi/asm/socket.h   |    4 +++-
 arch/avr32/include/uapi/asm/socket.h   |    2 ++
 arch/cris/include/uapi/asm/socket.h    |    2 ++
 arch/frv/include/uapi/asm/socket.h     |    2 ++
 arch/h8300/include/uapi/asm/socket.h   |    2 ++
 arch/ia64/include/uapi/asm/socket.h    |    2 ++
 arch/m32r/include/uapi/asm/socket.h    |    2 ++
 arch/mips/include/uapi/asm/socket.h    |    2 ++
 arch/mn10300/include/uapi/asm/socket.h |    2 ++
 arch/parisc/include/uapi/asm/socket.h  |    2 ++
 arch/powerpc/include/uapi/asm/socket.h |    2 ++
 arch/s390/include/uapi/asm/socket.h    |    2 ++
 arch/sparc/include/uapi/asm/socket.h   |    2 ++
 arch/xtensa/include/uapi/asm/socket.h  |    2 ++
 include/net/sock.h                     |    1 +
 include/uapi/asm-generic/socket.h      |    2 ++
 net/core/sock.c                        |   10 ++++++++++
 net/ipv4/tcp_input.c                   |    2 +-
 18 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 467de01..e3a1491 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -81,6 +81,8 @@
 
 #define SO_SELECT_ERR_QUEUE	45
 
-#define SO_BUSY_POLL			46
+#define SO_BUSY_POLL		46
+
+#define SO_MAX_PACING_RATE	47
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 11c4259..4399364 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -76,4 +76,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index eb723e5..13829aa 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -78,6 +78,8 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index f0cb1c3..5d42997 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -76,5 +76,7 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
index 9490758..214ccaf 100644
--- a/arch/h8300/include/uapi/asm/socket.h
+++ b/arch/h8300/include/uapi/asm/socket.h
@@ -76,4 +76,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 556d070..c25302f 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 24be7c8..5296665 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -76,4 +76,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 61c01f0..0df9787 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index e2a2b203..71dedca 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -76,4 +76,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 71700e6..7c614d0 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -75,6 +75,8 @@
 
 #define SO_BUSY_POLL		0x4027
 
+#define SO_MAX_PACING_RATE	0x4048
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a6d7446..fa69832 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -83,4 +83,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 9249449..c286c2e 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -82,4 +82,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 4e1d66c..0f21e9a 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -72,6 +72,8 @@
 
 #define SO_BUSY_POLL		0x0030
 
+#define SO_MAX_PACING_RATE	0x0031
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index c114483..7db5c22 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 4625d2e..240aa3f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -363,6 +363,7 @@ struct sock {
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
 	u32			sk_pacing_rate; /* bytes per second */
+	u32			sk_max_pacing_rate;
 	netdev_features_t	sk_route_caps;
 	netdev_features_t	sk_route_nocaps;
 	int			sk_gso_type;
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index f04b69b..38f14d0 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -78,4 +78,6 @@
 
 #define SO_BUSY_POLL		46
 
+#define SO_MAX_PACING_RATE	47
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 5b6beba..c02ccdf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -914,6 +914,11 @@ set_rcvbuf:
 		}
 		break;
 #endif
+
+	case SO_MAX_PACING_RATE:
+		sk->sk_max_pacing_rate = val;
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1177,6 +1182,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 #endif
 
+	case SO_MAX_PACING_RATE:
+		v.val = sk->sk_max_pacing_rate;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -2319,6 +2328,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_ll_usec		=	sysctl_net_busy_read;
 #endif
 
+	sk->sk_max_pacing_rate = ~0U;
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 25a89ea..75372c0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -713,7 +713,7 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	if (tp->srtt > 8 + 2)
 		do_div(rate, tp->srtt);
 
-	sk->sk_pacing_rate = min_t(u64, rate, ~0U);
+	sk->sk_pacing_rate = min_t(u64, rate, sk->sk_max_pacing_rate);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
