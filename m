From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 68/72] uapi ax25.h: glibc netax25/ax25.h header file compatibility fixes
Date: Mon, 22 Aug 2016 20:33:25 +0200
Message-ID: <1471890809-4383-69-git-send-email-mikko.rapeli__8625.35521523586$1471985772$gmane$org@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
        Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        linux-hams@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:59767 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755023AbcHWU4D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 16:56:03 -0400
Received: from lakka.kapsi.fi ([2001:1bc8:1004::1] ident=Debian-exim)
        by mail.kapsi.fi with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
        (Exim 4.80)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIjq-00056r-4M
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:56:02 +0300
Received: from mcfrisk by lakka.kapsi.fi with local (Exim 4.84_2)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIjq-0000a4-30
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:56:02 +0300
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes these userspace compile error when glibc netax25/ax25.h is included
before linux/ax25.h:

linux/ax25.h:28:0: warning: "SIOCAX25GETUID" redefined
linux/ax25.h:38:0: warning: "SIOCAX25GETINFO" redefined
linux/ax25.h:47:3: error: conflicting types for ‘ax25_address’
linux/ax25.h:49:8: error: redefinition of ‘struct sockaddr_ax25’
linux/ax25.h:58:8: error: redefinition of ‘struct full_sockaddr_ax25’
linux/ax25.h:63:8: error: redefinition of ‘struct ax25_routes_struct’
linux/ax25.h:70:8: error: redefinition of ‘struct ax25_route_opt_struct’
linux/ax25.h:77:8: error: redefinition of ‘struct ax25_ctl_struct’
linux/ax25.h:98:8: error: redefinition of ‘struct ax25_info_struct’
linux/ax25.h:111:8: error: redefinition of ‘struct ax25_fwd_struct’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/ax25.h        | 22 +++++++++++++++++++++
 include/uapi/linux/libc-compat.h | 41 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+)

diff --git a/include/uapi/linux/ax25.h b/include/uapi/linux/ax25.h
index 74c89a4..e296c8a 100644
--- a/include/uapi/linux/ax25.h
+++ b/include/uapi/linux/ax25.h
@@ -6,6 +6,7 @@
 #ifndef	AX25_KERNEL_H
 #define	AX25_KERNEL_H
 
+#include <linux/libc-compat.h>
 #include <linux/socket.h>
 
 #define AX25_MTU	256
@@ -25,6 +26,7 @@
 
 #define AX25_KILL	99
 
+#if __UAPI_DEF_SIOCAX25GETUID_TO_SIOCAX25DELFWD
 #define SIOCAX25GETUID		(SIOCPROTOPRIVATE+0)
 #define SIOCAX25ADDUID		(SIOCPROTOPRIVATE+1)
 #define SIOCAX25DELUID		(SIOCPROTOPRIVATE+2)
@@ -34,46 +36,61 @@
 #define SIOCAX25GETINFOOLD	(SIOCPROTOPRIVATE+9)
 #define SIOCAX25ADDFWD		(SIOCPROTOPRIVATE+10)
 #define SIOCAX25DELFWD		(SIOCPROTOPRIVATE+11)
+#endif /* __UAPI_DEF_SIOCAX25GETUID_TO_SIOCAX25DELFWD */
 #define SIOCAX25DEVCTL          (SIOCPROTOPRIVATE+12)
+/* glibc uses SIOCPROTOPRIVATE+9 for SIOCAX25GETINFO */
+#if __UAPI_DEF_SIOCAX25GETINFO
 #define SIOCAX25GETINFO         (SIOCPROTOPRIVATE+13)
+#endif /* __UAPI_DEF_SIOCAX25GETINFO */
 
 #define AX25_SET_RT_IPMODE	2
 
 #define AX25_NOUID_DEFAULT	0
 #define AX25_NOUID_BLOCK	1
 
+#if __UAPI_DEF_AX25_ADDRESS
 typedef struct {
 	char		ax25_call[7];	/* 6 call + SSID (shifted ascii!) */
 } ax25_address;
+#endif /* __UAPI_DEF_AX25_ADDRESS */
 
+#if __UAPI_DEF_SOCKADDR_AX25
 struct sockaddr_ax25 {
 	__kernel_sa_family_t sax25_family;
 	ax25_address	sax25_call;
 	int		sax25_ndigis;
 	/* Digipeater ax25_address sets follow */
 };
+#endif /* __UAPI_DEF_SOCKADDR_AX25 */
 
 #define sax25_uid	sax25_ndigis
 
+#if __UAPI_DEF_FULL_SOCKADDR_AX25
 struct full_sockaddr_ax25 {
 	struct sockaddr_ax25 fsa_ax25;
 	ax25_address	fsa_digipeater[AX25_MAX_DIGIS];
 };
+#endif /* __UAPI_DEF_FULL_SOCKADDR_AX25 */
 
+#if __UAPI_DEF_AX25_ROUTES_STRUCT
 struct ax25_routes_struct {
 	ax25_address	port_addr;
 	ax25_address	dest_addr;
 	unsigned char	digi_count;
 	ax25_address	digi_addr[AX25_MAX_DIGIS];
 };
+#endif /* __UAPI_DEF_AX25_ROUTES_STRUCT */
 
+#if __UAPI_DEF_AX25_ROUTES_OPT_STRUCT
 struct ax25_route_opt_struct {
 	ax25_address	port_addr;
 	ax25_address	dest_addr;
 	int		cmd;
 	int		arg;
 };
+#endif /* __UAPI_DEF_AX25_ROUTES_OPT_STRUCT */
 
+#if __UAPI_DEF_AX25_CTL_STRUCT
 struct ax25_ctl_struct {
         ax25_address            port_addr;
         ax25_address            source_addr;
@@ -83,6 +100,7 @@ struct ax25_ctl_struct {
         unsigned char           digi_count;
         ax25_address            digi_addr[AX25_MAX_DIGIS];
 };
+#endif /* __UAPI_DEF_AX25_CTL_STRUCT */
 
 /* this will go away. Please do not export to user land */
 struct ax25_info_struct_deprecated {
@@ -95,6 +113,7 @@ struct ax25_info_struct_deprecated {
 	unsigned int	rcv_q, snd_q;
 };
 
+#if __UAPI_DEF_AX25_INFO_STRUCT
 struct ax25_info_struct {
 	unsigned int	n2, n2count;
 	unsigned int	t1, t1timer;
@@ -107,10 +126,13 @@ struct ax25_info_struct {
 	unsigned int	paclen;
 	unsigned int	window;
 };
+#endif /* __UAPI_DEF_AX25_INFO_STRUCT */
 
+#if __UAPI_DEF_AX25_FWD_STRUCT
 struct ax25_fwd_struct {
 	ax25_address	port_from;
 	ax25_address	port_to;
 };
+#endif /* __UAPI_DEF_AX25_FWD_STRUCT */
 
 #endif
diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index f793b09..01bb521 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -100,6 +100,35 @@
 
 #endif /* _NET_IF_H */
 
+/* Coordinate with glibc netax25/ax25.h header. */
+#if defined(_NETAX25_AX25_H)
+
+#define __UAPI_DEF_SIOCAX25GETUID_TO_SIOCAX25DELFWD	0
+#define __UAPI_DEF_SIOCAX25GETINFO			0
+#define __UAPI_DEF_AX25_ADDRESS				0
+#define __UAPI_DEF_SOCKADDR_AX25			0
+#define __UAPI_DEF_FULL_SOCKADDR_AX25			0
+#define __UAPI_DEF_AX25_ROUTES_STRUCT			0
+#define __UAPI_DEF_AX25_ROUTES_OPT_STRUCT		0
+#define __UAPI_DEF_AX25_CTL_STRUCT			0
+#define __UAPI_DEF_AX25_INFO_STRUCT			0
+#define __UAPI_DEF_AX25_FWD_STRUCT			0
+
+#else /* defined(_NETAX25_AX25_H) */
+
+#define __UAPI_DEF_SIOCAX25GETUID_TO_SIOCAX25DELFWD	1
+#define __UAPI_DEF_SIOCAX25GETINFO			1
+#define __UAPI_DEF_AX25_ADDRESS				1
+#define __UAPI_DEF_SOCKADDR_AX25			1
+#define __UAPI_DEF_FULL_SOCKADDR_AX25			1
+#define __UAPI_DEF_AX25_ROUTES_STRUCT			1
+#define __UAPI_DEF_AX25_ROUTES_OPT_STRUCT		1
+#define __UAPI_DEF_AX25_CTL_STRUCT			1
+#define __UAPI_DEF_AX25_INFO_STRUCT			1
+#define __UAPI_DEF_AX25_FWD_STRUCT			1
+
+#endif /* defined(_NETAX25_AX25_H) */
+
 /* Coordinate with glibc netinet/in.h header. */
 #if defined(_NETINET_IN_H)
 
@@ -204,6 +233,18 @@
 #define __UAPI_DEF_F_DUPFD_CLOEXEC		1
 #define __UAPI_DEF_O_ACCMODE_RDONLY_WRONLY_RDWR	1
 
+/* Definitions for ax25.h */
+#define __UAPI_DEF_SIOCAX25GETUID_TO_SIOCAX25DELFWD	1
+#define __UAPI_DEF_SIOCAX25GETINFO			1
+#define __UAPI_DEF_AX25_ADDRESS				1
+#define __UAPI_DEF_SOCKADDR_AX25			1
+#define __UAPI_DEF_FULL_SOCKADDR_AX25			1
+#define __UAPI_DEF_AX25_ROUTES_STRUCT			1
+#define __UAPI_DEF_AX25_ROUTES_OPT_STRUCT		1
+#define __UAPI_DEF_AX25_CTL_STRUCT			1
+#define __UAPI_DEF_AX25_INFO_STRUCT			1
+#define __UAPI_DEF_AX25_FWD_STRUCT			1
+
 /* Definitions for if.h */
 #define __UAPI_DEF_IF_IFCONF 1
 #define __UAPI_DEF_IF_IFMAP 1
-- 
2.8.1
