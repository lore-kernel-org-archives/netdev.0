From: Michal Sekletar <msekleta@redhat.com>
Subject: [PATCH net-next v3] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 17 Jan 2014 17:09:45 +0100
Message-ID: <1389974985-21160-1-git-send-email-msekleta@redhat.com>
Cc: Michal Sekletar <msekleta@redhat.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027AbaAQQKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 11:10:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For user space packet capturing libraries such as libpcap, there's
currently only one way to check which BPF extensions are supported
by the kernel, that is, commit aa1113d9f85d ("net: filter: return
-EINVAL if BPF_S_ANC* operation is not supported"). For querying all
extensions at once this might be rather inconvenient.

Therefore, this patch introduces a new option which can be used as
an argument for getsockopt(), and allows one to obtain information
about which BPF extensions are supported by the current kernel.

As David Miller suggests, we do not need to define any bits right
now and status quo can just return 0 in order to state that this
versions supports SKF_AD_PROTOCOL up to SKF_AD_PAY_OFFSET. Later
additions to BPF extensions need to add their bits to the
bpf_tell_extensions() function, as documented in the comment.

Signed-off-by: Michal Sekletar <msekleta@redhat.com>
Cc: David Miller <davem@davemloft.net>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---

Dave, this will create a minor merge conflict with the net                                                                                                                                                                                   
tree when net-next is merged into Linus tree. The socket.h                                                                                                                                                                                   
in parisc architecture has for SO_MAX_PACING_RATE 0x4048                                                                                                                                                                                     
which should be merged to take the newly submitted 0x4028.                                                                                                                                                                                   

Thanks!

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
 include/linux/filter.h                 | 11 +++++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        |  4 ++++
 16 files changed, 43 insertions(+)

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
index ff4e40c..1a95a2d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -83,6 +83,17 @@ static inline void bpf_jit_free(struct sk_filter *fp)
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
 #endif
 
+static inline int bpf_tell_extensions(void)
+{
+	/* When adding new BPF extension it is necessary to enumerate
+	 * it here, so userspace software which wants to know what is
+	 * supported can do so by inspecting return value of this
+	 * function
+	 */
+
+	return 0;
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
index b3f7ee3..0c127dc 100644
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
