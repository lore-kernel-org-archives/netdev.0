From: Michal Sekletar <msekleta@redhat.com>
Subject: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 28 Nov 2013 12:57:12 +0100
Message-ID: <1385639832-3938-1-git-send-email-msekleta@redhat.com>
Cc: Michal Sekletar <msekleta@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53376 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754867Ab3K1L5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 06:57:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

userspace packet capturing libraries (e.g. libpcap) don't have a way how to find
out which BPF extensions are supported by the kernel, except compiling a filter
which uses extensions and trying to apply filter to the socket. This is very
inconvenient.

Therefore this commit introduces new option which can be used as an argument for
getsockopt() and allows one to obtain information about which BPF extensions are
supported by the kernel.

Signed-off-by: Michal Sekletar <msekleta@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
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
 include/linux/filter.h                 | 18 ++++++++++++++++++
 include/net/sock.h                     | 19 +++++++++++++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        |  4 ++++
 17 files changed, 69 insertions(+)

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
index 4399364..35e677e 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -78,4 +78,6 @@
 
 #define SO_MAX_PACING_RATE	47
 
+#define SO_BPF_EXTENSIONS	48
+
 #endif /* __ASM_AVR32_SOCKET_H */
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
index 7c614d0..e789b32 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -77,6 +77,8 @@
 
 #define SO_MAX_PACING_RATE	0x4048
 
+#define SO_BPF_EXTENSIONS	0x4029
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
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
index ff4e40c..9f0ea23 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -151,4 +151,22 @@ enum {
 	BPF_S_ANC_PAY_OFFSET,
 };
 
+enum {
+	BPF_ANC_FLAG_PROTOCOL         = (1 << 0),
+	BPF_ANC_FLAG_PKTTYPE          =	(1 << 1),
+	BPF_ANC_FLAG_IFINDEX          = (1 << 2),
+	BPF_ANC_FLAG_NLATTR           = (1 << 3),
+	BPF_ANC_FLAG_NLATTR_NEST      = (1 << 4),
+	BPF_ANC_FLAG_MARK             = (1 << 5),
+	BPF_ANC_FLAG_QUEUE            = (1 << 6),
+	BPF_ANC_FLAG_HATYPE           = (1 << 7),
+	BPF_ANC_FLAG_RXHASH           = (1 << 8),
+	BPF_ANC_FLAG_CPU              = (1 << 9),
+	BPF_ANC_FLAG_ALU_XOR_X        = (1 << 10),
+	BPF_ANC_FLAG_SECCOMP_LD_W     = (1 << 11),
+	BPF_ANC_FLAG_VLAN_TAG         = (1 << 12),
+	BPF_ANC_FLAG_VLAN_TAG_PRESENT = (1 << 13),
+	BPF_ANC_FLAG_PAY_OFFSET       = (1 << 14),
+};
+
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/net/sock.h b/include/net/sock.h
index e3a18ff..b0a1887 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2282,4 +2282,23 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+static inline int bpf_get_extensions(void)
+{
+	return BPF_ANC_FLAG_PROTOCOL |
+		BPF_ANC_FLAG_PKTTYPE |
+		BPF_ANC_FLAG_IFINDEX |
+		BPF_ANC_FLAG_NLATTR |
+		BPF_ANC_FLAG_NLATTR_NEST |
+		BPF_ANC_FLAG_MARK |
+		BPF_ANC_FLAG_QUEUE |
+		BPF_ANC_FLAG_HATYPE |
+		BPF_ANC_FLAG_RXHASH |
+		BPF_ANC_FLAG_CPU |
+		BPF_ANC_FLAG_ALU_XOR_X |
+		BPF_ANC_FLAG_SECCOMP_LD_W |
+		BPF_ANC_FLAG_VLAN_TAG |
+		BPF_ANC_FLAG_VLAN_TAG_PRESENT |
+		BPF_ANC_FLAG_PAY_OFFSET;
+}
+
 #endif	/* _SOCK_H */
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
index ab20ed9..2acec15 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1168,6 +1168,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_FILTER_LOCKED);
 		break;
 
+	case SO_BPF_EXTENSIONS:
+		v.val = bpf_get_extensions();
+		break;
+
 	case SO_SELECT_ERR_QUEUE:
 		v.val = sock_flag(sk, SOCK_SELECT_ERR_QUEUE);
 		break;
-- 
1.8.3.1
