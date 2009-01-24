From: Matt Helsley <matthltc@us.ibm.com>
Subject: [PATCH][RFC] Move config NET_NS to from net/Kconfig to init/Kconfig
Date: Fri, 23 Jan 2009 16:07:31 -0800
Message-ID: <1232755651.8282.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35259 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756668AbZAXAHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 19:07:33 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n0O06Xpr018396
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 17:06:33 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0O07Wxj209450
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 17:07:32 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0O07Wu1027146
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 17:07:32 -0700
Received: from [9.76.106.154] (sig-9-76-106-154.mts.ibm.com [9.76.106.154])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n0O07VrM027125
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 17:07:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make NET_NS available underneath the generic Namespaces config option since all of
the other namespace options are there.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---
 init/Kconfig |    8 ++++++++
 net/Kconfig  |    8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

Index: linux-2.6.29-rc1/init/Kconfig
===================================================================
--- linux-2.6.29-rc1.orig/init/Kconfig
+++ linux-2.6.29-rc1/init/Kconfig
@@ -541,6 +541,14 @@ config PID_NS
 	  Unless you want to work with an experimental feature
 	  say N here.
 
+config NET_NS
+	bool "Network namespace"
+	default n
+	depends on NAMESPACES && EXPERIMENTAL && NET
+	help
+	  Allow user space to create what appear to be multiple instances
+	  of the network stack.
+
 config BLK_DEV_INITRD
 	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
 	depends on BROKEN || !FRV
Index: linux-2.6.29-rc1/net/Kconfig
===================================================================
--- linux-2.6.29-rc1.orig/net/Kconfig
+++ linux-2.6.29-rc1/net/Kconfig
@@ -24,14 +24,6 @@ if NET
 
 menu "Networking options"
 
-config NET_NS
-	bool "Network namespace support"
-	default n
-	depends on EXPERIMENTAL && NAMESPACES
-	help
-	  Allow user space to create what appear to be multiple instances
-	  of the network stack.
-
 config COMPAT_NET_DEV_OPS
        def_bool y
 


