From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH][NET-2.6.25][IPV6] fix section mismatch warnings
Date: Thu, 13 Dec 2007 11:39:26 +0100
Message-ID: <47610BDE.9040907@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020903040802030504020804"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:28984 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761980AbXLMKni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 05:43:38 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBDAhYxT095450
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 10:43:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDAhYmg4944024
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 10:43:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDAhHkk014820
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 10:43:18 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020903040802030504020804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------020903040802030504020804
Content-Type: text/x-patch;
 name="fix-ipv6-section-mismatch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-ipv6-section-mismatch.patch"

Subject: fix section mismatch warnings
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Removed useless and buggy __exit section in the different 
ipv6 subsystems. Otherwise they will be called inside an
init section during rollbacking in case of an error in the
protocol initialization.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/addrconf.c |    2 +-
 net/ipv6/raw.c      |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 net/ipv6/udp.c      |    2 +-
 net/ipv6/udplite.c  |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

Index: net-2.6.25/net/ipv6/addrconf.c
===================================================================
--- net-2.6.25.orig/net/ipv6/addrconf.c
+++ net-2.6.25/net/ipv6/addrconf.c
@@ -4223,7 +4223,7 @@ errout:
 	return err;
 }
 
-void __exit addrconf_cleanup(void)
+void addrconf_cleanup(void)
 {
 	struct net_device *dev;
 	struct inet6_ifaddr *ifa;
Index: net-2.6.25/net/ipv6/raw.c
===================================================================
--- net-2.6.25.orig/net/ipv6/raw.c
+++ net-2.6.25/net/ipv6/raw.c
@@ -1321,7 +1321,7 @@ out:
 	return ret;
 }
 
-void __exit rawv6_exit(void)
+void rawv6_exit(void)
 {
 	inet6_unregister_protosw(&rawv6_protosw);
 }
Index: net-2.6.25/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6.25/net/ipv6/tcp_ipv6.c
@@ -2194,7 +2194,7 @@ out_tcpv6_protosw:
 	goto out;
 }
 
-void __exit tcpv6_exit(void)
+void tcpv6_exit(void)
 {
 	sock_release(tcp6_socket);
 	inet6_unregister_protosw(&tcpv6_protosw);
Index: net-2.6.25/net/ipv6/udp.c
===================================================================
--- net-2.6.25.orig/net/ipv6/udp.c
+++ net-2.6.25/net/ipv6/udp.c
@@ -1035,7 +1035,7 @@ out_udpv6_protocol:
 	goto out;
 }
 
-void __exit udpv6_exit(void)
+void udpv6_exit(void)
 {
 	inet6_unregister_protosw(&udpv6_protosw);
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
Index: net-2.6.25/net/ipv6/udplite.c
===================================================================
--- net-2.6.25.orig/net/ipv6/udplite.c
+++ net-2.6.25/net/ipv6/udplite.c
@@ -96,7 +96,7 @@ out_udplitev6_protocol:
 	goto out;
 }
 
-void __exit udplitev6_exit(void)
+void udplitev6_exit(void)
 {
 	inet6_unregister_protosw(&udplite6_protosw);
 	inet6_del_protocol(&udplitev6_protocol, IPPROTO_UDPLITE);

--------------020903040802030504020804--
