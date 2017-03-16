From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 3/5] net: Introduce SO_INCOMING_NAPI_ID
Date: Thu, 16 Mar 2017 11:32:50 -0700
Message-ID: <20170316183250.15806.59426.stgit@localhost.localdomain>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183142.15806.38824.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This socket option returns the napi id associated with the queue on which
the last frame is received. This information can be used by the apps to
split the incoming flows among the threads based on the Rx queue on which
they are received.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/alpha/include/uapi/asm/socket.h   |    2 ++
 arch/avr32/include/uapi/asm/socket.h   |    2 ++
 arch/frv/include/uapi/asm/socket.h     |    2 ++
 arch/ia64/include/uapi/asm/socket.h    |    2 ++
 arch/m32r/include/uapi/asm/socket.h    |    2 ++
 arch/mips/include/uapi/asm/socket.h    |    2 ++
 arch/mn10300/include/uapi/asm/socket.h |    2 ++
 arch/parisc/include/uapi/asm/socket.h  |    2 ++
 arch/powerpc/include/uapi/asm/socket.h |    2 ++
 arch/s390/include/uapi/asm/socket.h    |    2 ++
 arch/sparc/include/uapi/asm/socket.h   |    2 ++
 arch/xtensa/include/uapi/asm/socket.h  |    2 ++
 include/uapi/asm-generic/socket.h      |    2 ++
 net/core/sock.c                        |    4 ++++
 14 files changed, 30 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index afc901b7a6f6..c90a4eb8fe2d 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 5a650426f357..bee51e585ff6 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 81e03530ed39..4ac94eff4a64 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -92,5 +92,7 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 57feb0c1f7d7..1bb0c810495e 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -101,4 +101,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5853f8e92c20..234119518dc1 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 566ecdcb5b4b..0b6d2f0b82b4 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -110,4 +110,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 0e12527c4b0e..881fa88cbf60 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -92,4 +92,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 7a109b73ddf7..70d6f5ffebef 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	0x402F
 
+#define SO_INCOMING_NAPI_ID	0x4030
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 44583a52f882..8188f0ebae5f 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index b24a64cbfeb1..22ef97b26377 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index a25dc32f5d6a..6b7e10019763 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -88,6 +88,8 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	0x0038
 
+#define SO_INCOMING_NAPI_ID	0x0039
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 9fdbe1fe0473..77ba8be3738c 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2c748ddad5f8..e1ffc8d4aca3 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -94,4 +94,6 @@
 
 #define SCM_TIMESTAMPING_OPT_STATS	54
 
+#define SO_INCOMING_NAPI_ID	55
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index a83731c36761..74288b2d4b3d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1313,6 +1313,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_incoming_cpu;
 		break;
 
+	case SO_INCOMING_NAPI_ID:
+		v.val = sk->sk_napi_id;
+		break;
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
