From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v2 8/8] net: Introduce SO_INCOMING_NAPI_ID
Date: Thu, 23 Mar 2017 14:38:02 -0700
Message-ID: <20170323213802.12615.58216.stgit@localhost.localdomain>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36713 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbdCWVie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 17:38:34 -0400
In-Reply-To: <20170323211820.12615.88907.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This socket option returns the NAPI ID associated with the queue on which
the last frame is received. This information can be used by the apps to
split the incoming flows among the threads based on the Rx queue on which
they are received.

If the NAPI ID actually represents a sender_cpu then the value is ignored
and 0 is returned.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/alpha/include/uapi/asm/socket.h   |    2 ++
 arch/avr32/include/uapi/asm/socket.h   |    2 ++
 arch/frv/include/uapi/asm/socket.h     |    2 ++
 arch/ia64/include/uapi/asm/socket.h    |    2 ++
 arch/m32r/include/uapi/asm/socket.h    |    2 ++
 arch/mips/include/uapi/asm/socket.h    |    1 +
 arch/mn10300/include/uapi/asm/socket.h |    2 ++
 arch/parisc/include/uapi/asm/socket.h  |    2 ++
 arch/powerpc/include/uapi/asm/socket.h |    2 ++
 arch/s390/include/uapi/asm/socket.h    |    2 ++
 arch/sparc/include/uapi/asm/socket.h   |    2 ++
 arch/xtensa/include/uapi/asm/socket.h  |    2 ++
 include/uapi/asm-generic/socket.h      |    2 ++
 net/core/sock.c                        |   12 ++++++++++++
 14 files changed, 37 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 089db42c1b40..1bb8cac61a28 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 6eabcbd2f82a..f824eeb0f2e4 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index bd497f8356b9..a8ad9bebfc47 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -94,5 +94,7 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index f1bb54686168..6af3253e4209 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 459c46076f6f..e98b6bb897c0 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 688c18dd62ef..ae2b62e39d4d 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -112,5 +112,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 312d2c457a04..e4ac1843ee01 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index b98ec38f2083..f754c793e82a 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -93,4 +93,6 @@
 
 #define SO_MEMINFO		0x4030
 
+#define SO_INCOMING_NAPI_ID	0x4031
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 099a889240f6..5f84af7dcb2e 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 6199bb34f7fa..25ac4960e707 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -100,4 +100,6 @@
 
 #define	SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 12cd8c2ec422..b05513acd589 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -90,6 +90,8 @@
 
 #define SO_MEMINFO		0x0039
 
+#define SO_INCOMING_NAPI_ID	0x003a
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index d0b85f6c1484..786606c81edd 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -105,4 +105,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 8313702c1eae..c98a52fb572a 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_MEMINFO		55
 
+#define SO_INCOMING_NAPI_ID	56
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 0aa725cb3dd6..1de6c369ed86 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1328,6 +1328,18 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 		goto lenout;
 	}
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	case SO_INCOMING_NAPI_ID:
+		v.val = READ_ONCE(sk->sk_napi_id);
+
+		/* aggregate non-NAPI IDs down to 0 */
+		if (v.val < MIN_NAPI_ID)
+			v.val = 0;
+
+		break;
+#endif
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
