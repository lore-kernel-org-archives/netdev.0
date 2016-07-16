From: Magnus Bergroth <bergroth@nordu.net>
Subject: iproute2 mpls max labels
Date: Sat, 16 Jul 2016 20:24:48 +0200
Message-ID: <578A7BF0.2020107@nordu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e-mailfilter02.sunet.se ([192.36.171.202]:52144 "EHLO
	e-mailfilter02.sunet.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbcGPSec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 14:34:32 -0400
Received: from smtp1.nordu.net (smtp1.nordu.net [IPv6:2001:948:4:6::32])
	by e-mailfilter02.sunet.se (8.14.4/8.14.4/Debian-4) with ESMTP id u6GIOsWV031722
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2016 20:24:54 +0200
Received: from Hugo2-204.local (h-20-185.a259.priv.bahnhof.se [79.136.20.185])
	(authenticated bits=0)
	by smtp1.nordu.net (8.14.7/8.14.7) with ESMTP id u6GIOojh002851
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2016 18:24:54 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wanted to use more than the default maximum of 8 mpls labels. Max labels
seems to be hardcode to 8 in two places.

--- iproute2-4.6.0/lib/utils.c    2016-05-18 20:56:02.000000000 +0200
+++ iproute2-4.6.0-bergroth/lib/utils.c    2016-07-16 20:12:10.714958071
+0200
@@ -476,7 +476,7 @@
         addr->bytelen = 4;
         addr->bitlen = 20;
         /* How many bytes do I need? */
-        for (i = 0; i < 8; i++) {
+        for (i = 0; i < MPLS_MAX_LABELS; i++) {
             if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
                 addr->bytelen = (i + 1)*4;
                 break;


--- iproute2-4.6.0/include/utils.h    2016-05-18 20:56:02.000000000 +0200
+++ iproute2-4.6.0-bergroth/include/utils.h    2016-07-15
11:55:57.297681742 +0200
@@ -54,6 +54,9 @@
 #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
 #define PREV_ARG() do { argv--; argc++; } while(0)

+/* Maximum number of labels the mpls helpers support */
+#define MPLS_MAX_LABELS 8
+
 typedef struct
 {
     __u16 flags;
@@ -61,7 +64,7 @@
     __s16 bitlen;
     /* These next two fields match rtvia */
     __u16 family;
-    __u32 data[8];
+    __u32 data[MPLS_MAX_LABELS];
 } inet_prefix;

 #define PREFIXLEN_SPECIFIED 1
@@ -88,9 +91,6 @@
 # define AF_MPLS 28
 #endif

-/* Maximum number of labels the mpls helpers support */
-#define MPLS_MAX_LABELS 8
-
 __u32 get_addr32(const char *name);
 int get_addr_1(inet_prefix *dst, const char *arg, int family);
 int get_prefix_1(inet_prefix *dst, char *arg, int family);




Kindly

Magnus Bergroth
