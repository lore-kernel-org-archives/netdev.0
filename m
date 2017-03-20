From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH] sock: introduce SO_MEMINFO getsockopt
Date: Mon, 20 Mar 2017 15:22:03 -0400
Message-ID: <1490037723-6475-1-git-send-email-johunt@akamai.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, jbaron@akamai.com,
        ckuiper@google.com, pgynther@google.com,
        Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:9361 "EHLO
        prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752569AbdCTTY1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 15:24:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows reading of SK_MEMINFO_VARS via socket option. This way an
application can get all meminfo related information in single socket
option call instead of multiple calls.

Adds helper function, sk_get_meminfo(), and uses that for both
getsockopt and sock_diag_put_meminfo().

Suggested by Eric Dumazet.

Signed-off-by: Josh Hunt <johunt@akamai.com>
Reviewed-by: Jason Baron <jbaron@akamai.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  3 +++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/net/sock.h                     |  2 ++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        | 30 ++++++++++++++++++++++++++++++
 net/core/sock_diag.c                   | 10 +---------
 16 files changed, 60 insertions(+), 9 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index afc901b..089db42 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 5a65042..6eabcbd 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 81e0353..bd497f8 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -92,5 +92,7 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 57feb0c..f1bb546 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5853f8e9..459c460 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 566ecdc..688c18d 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -110,4 +110,7 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 0e12527..312d2c4 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 7a109b7..b98ec38 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	0x402F
 
+#define SO_MEMINFO		0x4030
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 44583a5..099a889 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index b24a64c..6199bb3 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define	SO_MEMINFO		55
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index a25dc32..12cd8c2 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -88,6 +88,8 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	0x0038
 
+#define SO_MEMINFO		0x0039
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 9fdbe1f..d0b85f6 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 08142be..cb241a0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2362,6 +2362,8 @@ bool sk_ns_capable(const struct sock *sk,
 bool sk_capable(const struct sock *sk, int cap);
 bool sk_net_capable(const struct sock *sk, int cap);
 
+void sk_get_meminfo(const struct sock *sk, u32 *meminfo);
+
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2c748dd..8313702 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -94,4 +94,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_MEMINFO		55
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index a83731c..f8c0373 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1313,6 +1313,21 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_incoming_cpu;
 		break;
 
+	case SO_MEMINFO:
+	{
+		u32 meminfo[SK_MEMINFO_VARS];
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+
+		sk_get_meminfo(sk, meminfo);
+
+		len = min_t(unsigned int, len, sizeof(meminfo));
+		if (copy_to_user(optval, &meminfo, len))
+			return -EFAULT;
+
+		goto lenout;
+	}
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
@@ -2861,6 +2876,21 @@ void sk_common_release(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_common_release);
 
+void sk_get_meminfo(const struct sock *sk, u32 *mem)
+{
+	memset(mem, 0, sizeof(*mem) * SK_MEMINFO_VARS);
+
+	mem[SK_MEMINFO_RMEM_ALLOC] = sk_rmem_alloc_get(sk);
+	mem[SK_MEMINFO_RCVBUF] = sk->sk_rcvbuf;
+	mem[SK_MEMINFO_WMEM_ALLOC] = sk_wmem_alloc_get(sk);
+	mem[SK_MEMINFO_SNDBUF] = sk->sk_sndbuf;
+	mem[SK_MEMINFO_FWD_ALLOC] = sk->sk_forward_alloc;
+	mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
+	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
+	mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
+	mem[SK_MEMINFO_DROPS] = atomic_read(&sk->sk_drops);
+}
+
 #ifdef CONFIG_PROC_FS
 #define PROTO_INUSE_NR	64	/* should be enough for the first time */
 struct prot_inuse {
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 6b10573..8d11ee7 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -59,15 +59,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 {
 	u32 mem[SK_MEMINFO_VARS];
 
-	mem[SK_MEMINFO_RMEM_ALLOC] = sk_rmem_alloc_get(sk);
-	mem[SK_MEMINFO_RCVBUF] = sk->sk_rcvbuf;
-	mem[SK_MEMINFO_WMEM_ALLOC] = sk_wmem_alloc_get(sk);
-	mem[SK_MEMINFO_SNDBUF] = sk->sk_sndbuf;
-	mem[SK_MEMINFO_FWD_ALLOC] = sk->sk_forward_alloc;
-	mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
-	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
-	mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
-	mem[SK_MEMINFO_DROPS] = atomic_read(&sk->sk_drops);
+	sk_get_meminfo(sk, mem);
 
 	return nla_put(skb, attrtype, sizeof(mem), &mem);
 }
-- 
1.9.1
