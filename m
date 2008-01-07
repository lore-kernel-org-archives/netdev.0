From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH net-2.6.25][NETNS][IPV6] add ipv6 structure for netns
Date: Mon, 07 Jan 2008 21:48:11 +0100
Message-ID: <4782900B.9040608@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070105050402070108010409"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:20702 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbYAGU5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 15:57:43 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m07KvgAL043190
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:42 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m07KvgE24956236
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:42 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m07KvPO0016863
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:25 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070105050402070108010409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070105050402070108010409
Content-Type: text/x-patch;
 name="add-ipv6-for-netns.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="add-ipv6-for-netns.patch"

Subject: add ipv6 structure for netns
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Like the ipv4 part, this patch adds an ipv6 structure in the net structure
to aggregate the different resources to make ipv6 per namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/net_namespace.h |    4 ++++
 include/net/netns/ipv6.h    |   10 ++++++++++
 2 files changed, 14 insertions(+)

Index: net-2.6.25/include/net/net_namespace.h
===================================================================
--- net-2.6.25.orig/include/net/net_namespace.h
+++ net-2.6.25/include/net/net_namespace.h
@@ -11,6 +11,7 @@
 #include <net/netns/unix.h>
 #include <net/netns/packet.h>
 #include <net/netns/ipv4.h>
+#include <net/netns/ipv6.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -48,6 +49,9 @@ struct net {
 	struct netns_packet	packet;
 	struct netns_unix	unx;
 	struct netns_ipv4	ipv4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct netns_ipv6	ipv6;
+#endif
 };
 
 #ifdef CONFIG_NET
Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- /dev/null
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -0,0 +1,10 @@
+/*
+ * ipv6 in net namespaces
+ */
+
+#ifndef __NETNS_IPV6_H__
+#define __NETNS_IPV6_H__
+
+struct netns_ipv6 {
+};
+#endif

--------------070105050402070108010409--
