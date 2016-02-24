From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] net: Facility to report route quality of connected sockets
Date: Wed, 24 Feb 2016 10:02:52 -0800
Message-ID: <1456336972-3024417-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58473 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758526AbcBXSDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:03:04 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1OHv5mK010119
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:03:04 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 21950wamx2-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:03:03 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 d85158eadb2011e59a6e0002c9521c9e-a64f0270 for <netdev@vger.kernel.org>;	Wed,
 24 Feb 2016 10:03:02 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the SO_CNX_ADVICE socket option (setsockopt only). The
purpose is to allow an application to give feedback to the kernel about
the quality of the network path for a connected socket. The value
argument indicates the type of quality report. For this initial patch
the only supported advice is a value of 1 which indicates "bad path,
please reroute"-- the action taken by the kernel is to call
dst_negative_advice which will attempt to choose a different ECMP route,
reset the TX hash for flow label and UDP source port in encapsulation,
etc.

This facility should be useful for connected UDP sockets where only the
application can provide any feedback about path quality. It could also
be useful for TCP applications that have additional knowledge about the
path outside of the normal TCP control loop.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 arch/alpha/include/uapi/asm/socket.h   | 2 ++
 arch/avr32/include/uapi/asm/socket.h   | 2 ++
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
 include/uapi/asm-generic/socket.h      | 2 ++
 net/core/sock.c                        | 4 ++++
 14 files changed, 30 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index c5fb9e6..9e46d6e 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -95,4 +95,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 9de0796..1fd147f 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -88,4 +88,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index f02e484..afbc98f0 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -88,5 +88,7 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index bce2916..0018fad 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 14aa4a6..5fe42fc 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -88,4 +88,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 5910fe2..2027240a 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -106,4 +106,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 58b1aa0..5129f23 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -88,4 +88,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index f9cf122..9c935d7 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	0x402C
 #define SO_ATTACH_REUSEPORT_EBPF	0x402D
 
+#define SO_CNX_ADVICE		0x402E
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index dd54f28..1672e33 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -95,4 +95,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index d02e89d..41b51c2 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -94,4 +94,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index d270ee9..31aede3 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -84,6 +84,8 @@
 #define SO_ATTACH_REUSEPORT_CBPF	0x0035
 #define SO_ATTACH_REUSEPORT_EBPF	0x0036
 
+#define SO_CNX_ADVICE		0x0037
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index fd3b96d..81435d9 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -99,4 +99,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index fb8a416..67d632f 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -90,4 +90,6 @@
 #define SO_ATTACH_REUSEPORT_CBPF	51
 #define SO_ATTACH_REUSEPORT_EBPF	52
 
+#define SO_CNX_ADVICE		53
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 46dc8ad..4493ff8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -987,6 +987,10 @@ set_rcvbuf:
 		sk->sk_incoming_cpu = val;
 		break;
 
+	case SO_CNX_ADVICE:
+		if (val == 1)
+			dst_negative_advice(sk);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
-- 
2.6.5
