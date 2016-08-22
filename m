From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v05 69/72] uapi rose.h: glibc netrose/rose.h header file compatibility fixes
Date: Mon, 22 Aug 2016 20:33:26 +0200
Message-ID: <1471890809-4383-70-git-send-email-mikko.rapeli__22288.8609896929$1471985782$gmane$org@iki.fi>
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
Received: from mail.kapsi.fi ([217.30.184.167]:47209 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754698AbcHWU4M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 16:56:12 -0400
Received: from lakka.kapsi.fi ([2001:1bc8:1004::1] ident=Debian-exim)
        by mail.kapsi.fi with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
        (Exim 4.80)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIjy-00059v-AG
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:56:10 +0300
Received: from mcfrisk by lakka.kapsi.fi with local (Exim 4.84_2)
        (envelope-from <mikko.rapeli@iki.fi>)
        id 1bcIjy-0000u4-8v
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:56:10 +0300
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes these userspace compile errors and warnings when glibc
netrose/rose.h is included before linux/rose.h:

linux/rose.h:25:0: warning: "SIOCRSGCAUSE" redefined
linux/rose.h:26:0: warning: "SIOCRSSCAUSE" redefined
linux/rose.h:27:0: warning: "SIOCRSL2CALL" redefined
linux/rose.h:28:0: warning: "SIOCRSSL2CALL" redefined
linux/rose.h:29:0: warning: "SIOCRSACCEPT" redefined
linux/rose.h:30:0: warning: "SIOCRSCLRRT" redefined
linux/rose.h:31:0: warning: "SIOCRSGL2CALL" redefined
linux/rose.h:32:0: warning: "SIOCRSGFACILITIES" redefined
linux/rose.h:47:3: error: conflicting types for ‘rose_address’
linux/rose.h:49:8: error: redefinition of ‘struct sockaddr_rose’
linux/rose.h:57:8: error: redefinition of ‘struct full_sockaddr_rose’
linux/rose.h:65:8: error: redefinition of ‘struct rose_route_struct’
linux/rose.h:74:8: error: redefinition of ‘struct rose_cause_struct’
linux/rose.h:79:8: error: redefinition of ‘struct rose_facilities_struct’

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/libc-compat.h | 30 ++++++++++++++++++++++++++++++
 include/uapi/linux/rose.h        | 15 +++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 01bb521..acc2e75 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -209,6 +209,27 @@
 
 #endif /* defined(__NETIPX_IPX_H) */
 
+/* Coordinate with glibc netrose/rose.h */
+#if defined(_NETROSE_ROSE_H)
+#define __UAPI_DEF_SIOCRSGCAUSE_TO_SIOCRSGFACILITIES	0
+#define __UAPI_DEF_ROSE_ADDRESS				0
+#define __UAPI_DEF_SOCKADDR_ROSE			0
+#define __UAPI_DEF_FULL_SOCKADDR_ROSE			0
+#define __UAPI_DEF_ROSE_ROUTE_STRUCT			0
+#define __UAPI_DEF_ROSE_CAUSE_STRUCT			0
+#define __UAPI_DEF_ROSE_FACILITIES_STRUCT		0
+
+#else /* defined(_NETROSE_ROSE_H) */
+#define __UAPI_DEF_SIOCRSGCAUSE_TO_SIOCRSGFACILITIES	1
+#define __UAPI_DEF_ROSE_ADDRESS				1
+#define __UAPI_DEF_SOCKADDR_ROSE			1
+#define __UAPI_DEF_FULL_SOCKADDR_ROSE			1
+#define __UAPI_DEF_ROSE_ROUTE_STRUCT			1
+#define __UAPI_DEF_ROSE_CAUSE_STRUCT			1
+#define __UAPI_DEF_ROSE_FACILITIES_STRUCT		1
+
+#endif /* defined(_NETROSE_ROSE_H) */
+
 /* Definitions for sys/uio.h */
 #if defined(_SYS_UIO_H)
 #define __UAPI_DEF_IOVEC		0
@@ -283,6 +304,15 @@
 #define __UAPI_DEF_IPX_CONFIG_DATA		1
 #define __UAPI_DEF_IPX_ROUTE_DEF		1
 
+/* Definitions for rose.h */
+#define __UAPI_DEF_SIOCRSGCAUSE_TO_SIOCRSGFACILITIES	1
+#define __UAPI_DEF_ROSE_ADDRESS				1
+#define __UAPI_DEF_SOCKADDR_ROSE			1
+#define __UAPI_DEF_FULL_SOCKADDR_ROSE			1
+#define __UAPI_DEF_ROSE_ROUTE_STRUCT			1
+#define __UAPI_DEF_ROSE_CAUSE_STRUCT			1
+#define __UAPI_DEF_ROSE_FACILITIES_STRUCT		1
+
 /* Definitions for uio.h */
 #define __UAPI_DEF_IOVEC		1
 
diff --git a/include/uapi/linux/rose.h b/include/uapi/linux/rose.h
index 1fcfe95..c39499c 100644
--- a/include/uapi/linux/rose.h
+++ b/include/uapi/linux/rose.h
@@ -7,6 +7,7 @@
 #ifndef	ROSE_KERNEL_H
 #define	ROSE_KERNEL_H
 
+#include <linux/libc-compat.h>
 #include <linux/socket.h>
 #include <linux/ax25.h>
 
@@ -22,6 +23,7 @@
 #define	ROSE_QBITINCL	6
 #define	ROSE_HOLDBACK	7
 
+#if __UAPI_DEF_SIOCRSGCAUSE_TO_SIOCRSGFACILITIES
 #define	SIOCRSGCAUSE		(SIOCPROTOPRIVATE+0)
 #define	SIOCRSSCAUSE		(SIOCPROTOPRIVATE+1)
 #define	SIOCRSL2CALL		(SIOCPROTOPRIVATE+2)
@@ -30,6 +32,7 @@
 #define	SIOCRSCLRRT		(SIOCPROTOPRIVATE+4)
 #define	SIOCRSGL2CALL		(SIOCPROTOPRIVATE+5)
 #define	SIOCRSGFACILITIES	(SIOCPROTOPRIVATE+6)
+#endif /* __UAPI_DEF_SIOCRSGCAUSE_TO_SIOCRSGFACILITIES */
 
 #define	ROSE_DTE_ORIGINATED	0x00
 #define	ROSE_NUMBER_BUSY	0x01
@@ -42,10 +45,13 @@
 #define	ROSE_LOCAL_PROCEDURE	0x13
 #define	ROSE_SHIP_ABSENT	0x39
 
+#if __UAPI_DEF_ROSE_ADDRESS
 typedef struct {
 	char		rose_addr[5];
 } rose_address;
+#endif /* __UAPI_DEF_ROSE_ADDRESS */
 
+#if __UAPI_DEF_SOCKADDR_ROSE
 struct sockaddr_rose {
 	__kernel_sa_family_t srose_family;
 	rose_address	srose_addr;
@@ -53,7 +59,9 @@ struct sockaddr_rose {
 	int		srose_ndigis;
 	ax25_address	srose_digi;
 };
+#endif /* __UAPI_DEF_SOCKADDR_ROSE */
 
+#if __UAPI_DEF_FULL_SOCKADDR_ROSE
 struct full_sockaddr_rose {
 	__kernel_sa_family_t srose_family;
 	rose_address	srose_addr;
@@ -61,7 +69,9 @@ struct full_sockaddr_rose {
 	unsigned int	srose_ndigis;
 	ax25_address	srose_digis[ROSE_MAX_DIGIS];
 };
+#endif /* __UAPI_DEF_FULL_SOCKADDR_ROSE */
 
+#if __UAPI_DEF_ROSE_ROUTE_STRUCT
 struct rose_route_struct {
 	rose_address	address;
 	unsigned short	mask;
@@ -70,12 +80,16 @@ struct rose_route_struct {
 	unsigned char	ndigis;
 	ax25_address	digipeaters[AX25_MAX_DIGIS];
 };
+#endif /* __UAPI_DEF_ROSE_ROUTE_STRUCT */
 
+#if __UAPI_DEF_ROSE_CAUSE_STRUCT
 struct rose_cause_struct {
 	unsigned char	cause;
 	unsigned char	diagnostic;
 };
+#endif /* __UAPI_DEF_ROSE_CAUSE_STRUCT */
 
+#if __UAPI_DEF_ROSE_FACILITIES_STRUCT
 struct rose_facilities_struct {
 	rose_address	source_addr,   dest_addr;
 	ax25_address	source_call,   dest_call;
@@ -86,5 +100,6 @@ struct rose_facilities_struct {
 	rose_address	fail_addr;
 	ax25_address	fail_call;
 };
+#endif /* __UAPI_DEF_ROSE_FACILITIES_STRUCT */
 
 #endif
-- 
2.8.1
