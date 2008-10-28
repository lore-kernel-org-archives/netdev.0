From: Vivien Chappelier <vivien.chappelier@thomson.net>
Subject: [PATCH 4/6] netns: Add SO_NSID and SO_NETID socket option
Date: Tue, 28 Oct 2008 18:44:40 +0100
Message-ID: <20081028174440.GD8471@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmzraw4.extranet.thmulti.com ([141.11.234.72]:33368 "EHLO
	dmzraw4.extranet.thmulti.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752713AbYJ1Rol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 13:44:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SO_NSID: bind a socket to a network namespace, given its nsid

This allows a process to have individual sockets in different namespaces.
Also, calling setsockopt(SO_NSID) on a socket before using it for ioctl() make the ioctl() operations happen in the given namespace. This is very useful to configure or retrieve networking information in a different namespace.

SO_NETNS: bind a process to an already existing netns, given its nsid

This is an easy way to move a process to a different, already existing, network namespace without creating a new one.

---
 arch/alpha/include/asm/socket.h    |    4 +++
 arch/arm/include/asm/socket.h      |    4 +++
 arch/avr32/include/asm/socket.h    |    4 +++
 arch/blackfin/include/asm/socket.h |    4 +++
 arch/h8300/include/asm/socket.h    |    4 +++
 arch/ia64/include/asm/socket.h     |    4 +++
 arch/mips/include/asm/socket.h     |    4 +++
 arch/parisc/include/asm/socket.h   |    4 +++
 arch/powerpc/include/asm/socket.h  |    4 +++
 arch/s390/include/asm/socket.h     |    4 +++
 arch/sh/include/asm/socket.h       |    4 +++
 arch/sparc/include/asm/socket.h    |    4 +++
 arch/x86/include/asm/socket.h      |    4 +++
 include/asm-cris/socket.h          |    4 +++
 include/asm-frv/socket.h           |    4 +++
 include/asm-m32r/socket.h          |    4 +++
 include/asm-m68k/socket.h          |    4 +++
 include/asm-mn10300/socket.h       |    4 +++
 include/asm-xtensa/socket.h        |    4 +++
 net/core/sock.c                    |   47 +++++++++++++++++++++++++++++++++++-
 20 files changed, 122 insertions(+), 1 deletions(-)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index a1057c2..e9f3f47 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -62,6 +62,10 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index 6817be9..5162369 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index 35863f2..d500536 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/blackfin/include/asm/socket.h b/arch/blackfin/include/asm/socket.h
index 2ca702e..a56fc0f 100644
--- a/arch/blackfin/include/asm/socket.h
+++ b/arch/blackfin/include/asm/socket.h
@@ -53,4 +53,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif				/* _ASM_SOCKET_H */
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index da2520d..112c632 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index d5ef0aa..246b075 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -63,4 +63,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index facc2d7..d90fadb 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -75,6 +75,10 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index fba402c..cebbd8b 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -54,6 +54,10 @@
 
 #define SO_MARK			0x401f
 
+/* Namespace management */
+#define SO_NETNS		0x4020
+#define SO_NSID			0x4021
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index f5a4e16..68e9a53 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -61,4 +61,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index c786ab6..48a2e1f 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -62,4 +62,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sh/include/asm/socket.h b/arch/sh/include/asm/socket.h
index 6d4bf65..3e1ae9a 100644
--- a/arch/sh/include/asm/socket.h
+++ b/arch/sh/include/asm/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* __ASM_SH_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index bf50d0c..e64381c 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -50,6 +50,10 @@
 
 #define SO_MARK			0x0022
 
+/* Namespace management */
+#define SO_NETNS		0x0023
+#define SO_NSID			0x0024
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/x86/include/asm/socket.h b/arch/x86/include/asm/socket.h
index 8ab9cc8..9023180 100644
--- a/arch/x86/include/asm/socket.h
+++ b/arch/x86/include/asm/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_X86_SOCKET_H */
diff --git a/include/asm-cris/socket.h b/include/asm-cris/socket.h
index 9df0ca8..7550720 100644
--- a/include/asm-cris/socket.h
+++ b/include/asm-cris/socket.h
@@ -56,6 +56,10 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/include/asm-frv/socket.h b/include/asm-frv/socket.h
index e51ca67..2ea7442 100644
--- a/include/asm-frv/socket.h
+++ b/include/asm-frv/socket.h
@@ -54,5 +54,9 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/include/asm-m32r/socket.h b/include/asm-m32r/socket.h
index 9a0e200..06de900 100644
--- a/include/asm-m32r/socket.h
+++ b/include/asm-m32r/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/include/asm-m68k/socket.h b/include/asm-m68k/socket.h
index dbc64e9..b208e7c 100644
--- a/include/asm-m68k/socket.h
+++ b/include/asm-m68k/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-mn10300/socket.h b/include/asm-mn10300/socket.h
index 80af9c4..6665cb8 100644
--- a/include/asm-mn10300/socket.h
+++ b/include/asm-mn10300/socket.h
@@ -54,4 +54,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-xtensa/socket.h b/include/asm-xtensa/socket.h
index 6100682..7882935 100644
--- a/include/asm-xtensa/socket.h
+++ b/include/asm-xtensa/socket.h
@@ -65,4 +65,8 @@
 
 #define SO_MARK			36
 
+/* Namespace management */
+#define SO_NETNS		37
+#define SO_NSID			38
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 5e2a313..b085f67 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -110,6 +110,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/nsproxy.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -668,7 +669,51 @@ set_rcvbuf:
 		}
 		break;
 
-		/* We implement the SO_SNDLOWAT etc to
+	case SO_NETNS:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret = -EPERM;
+		} else {
+			struct nsproxy *new_nsproxy;
+			struct net *old_net, *new_net;
+
+			ret = -EINVAL;
+			new_net = get_net_ns_by_id(val);
+			if (new_net) {
+				ret = unshare_nsproxy_namespaces(CLONE_NEWNS,
+								 &new_nsproxy,
+								 NULL);
+				if (ret == 0) {
+					old_net = new_nsproxy->net_ns;
+					new_nsproxy->net_ns = new_net;
+					put_net(old_net);
+
+					switch_task_namespaces(current,
+							       new_nsproxy);
+				} else
+					put_net(new_net);
+			}
+		}
+		break;
+
+	case SO_NSID:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret = -EPERM;
+		} else {
+			struct net *old_net, *new_net;
+
+			ret = -EINVAL;
+			new_net = get_net_ns_by_id(val);
+			if (new_net) {
+				ret = 0;
+				old_net = sock_net(sk);
+				sock_net_set(sk, get_net(new_net));
+				put_net(old_net);
+			}
+		}
+		break;
+
+
+	/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
 	default:
 		ret = -ENOPROTOOPT;
-- 
1.5.4.4

