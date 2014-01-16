From: Michal Sekletar <msekleta@redhat.com>
Subject: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 16 Jan 2014 18:13:39 +0100
Message-ID: <1389892419-11877-1-git-send-email-msekleta@redhat.com>
References: <52D80BCA.7030400@redhat.com>
Cc: netdev@vger.kernel.org, Michal Sekletar <msekleta@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61265 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754AbaAPROI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 12:14:08 -0500
In-Reply-To: <52D80BCA.7030400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

userspace packet capturing libraries (e.g. libpcap) don't have a way how to find
out which BPF extensions are supported by the kernel, except compiling a filter
which uses extensions and trying to apply filter to the socket. This is very
inconvenient.

Therefore this commit introduces new option which can be used as an argument for
getsockopt() and allows one to obtain information about which BPF extensions are
supported by the kernel.

On Tue, Dec 10, 2013 at 1:25 AM, David Miller <davem@davemloft.net> wrote:

> And therefore, you do not need to define any actual bits yet. The
> socket option will for now just return "0", and that will mean that
> all the extensions Linux implements currently are presnet.

Signed-off-by: Michal Sekletar <msekleta@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: David Miller <davem@davemloft.net>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/cris/include/uapi/asm/socket.h    |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/linux/filter.h                 | 10 ++++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        |  4 ++++
 16 files changed, 42 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index e3a1491..3de1394 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index cbf902e..6e6cd15 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -78,4 +78,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index 13829aa..ed94e5e 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -80,6 +80,8 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 5d42997..ca2c6e6 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -78,5 +78,7 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index c25302f..a1b49ba 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5296665..6c9a24b 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -78,4 +78,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 0df9787..a14baa2 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 71dedca..6aa3ce1 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -78,4 +78,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index f33113a..a586f61 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -77,4 +77,6 @@
 
 #define SO_MAX_PACING_RATE	0x4048
 
+#define SO_BPF_EXTENSIONS	0x4029
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index fa69832..a9c3e2e 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -85,4 +85,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index c286c2e..e031332 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -84,4 +84,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 0f21e9a..54d9608 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -74,6 +74,8 @@
 
 #define SO_MAX_PACING_RATE	0x0031
 
+#define SO_BPF_EXTENSIONS	0x0032
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 7db5c22..39acec0 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index ff4e40c..3c9a7fc 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -83,6 +83,16 @@ static inline void bpf_jit_free(struct sk_filter *fp)
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
 #endif
 
+static inline int bpf_tell_extensions(void)
+{
+        /* When adding new BPF extension it is necessary to enumerate it here, so
+         * userspace software which wants to know what is supported can do so by inspecting
+         * return value of this function
+         */
+
+        return 0;
+}
+
 enum {
 	BPF_S_RET_K = 1,
 	BPF_S_RET_A,
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 38f14d0..ea0796b 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 85ad6f0..4a32e52 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1167,6 +1167,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_FILTER_LOCKED);
 		break;
 
+	case SO_BPF_EXTENSIONS:
+		v.val = bpf_tell_extensions();
+		break;
+
 	case SO_SELECT_ERR_QUEUE:
 		v.val = sock_flag(sk, SOCK_SELECT_ERR_QUEUE);
 		break;
-- 
1.8.4.2
