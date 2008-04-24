From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH][IPROUTE2] Support device movement between network namespaces
Date: Thu, 24 Apr 2008 17:15:38 +0200
Message-ID: <20080424151630.970357562@theryb.frec.bull.fr>
References: <20080424151528.746600079@theryb.frec.bull.fr>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50355 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764232AbYDXP01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 11:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I don't know if anyone has already sent you this patch for iproute2 to
enable movement of network devices between network namespaces. 
(Daniel Lezcano is the original author). 

It applies on iproute2-2.6.25.

Benjamin


This patch adds support for the IFLA_NET_NS_PID type used to move 
network devices between network namespaces.

The syntax is: 
ip link DEVICE netns PID

PID is the pid of a process in the target network namespace.

---
 ip/iplink.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: iproute2-2.6.25/ip/iplink.c
===================================================================
--- iproute2-2.6.25.orig/ip/iplink.c
+++ iproute2-2.6.25/ip/iplink.c
@@ -49,6 +49,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
 	fprintf(stderr, "	                     mtu MTU }\n");
+	fprintf(stderr, "	                     netns PID }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 	exit(-1);
 }
@@ -156,6 +157,7 @@ int iplink_parse(int argc, char **argv, 
 	char abuf[32];
 	int qlen = -1;
 	int mtu = -1;
+	int netns = -1;
 
 	ret = argc;
 
@@ -197,6 +199,13 @@ int iplink_parse(int argc, char **argv, 
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
+                } else if (strcmp(*argv, "netns") == 0) {
+                        NEXT_ARG();
+                        if (netns != -1)
+                                duparg("netns", *argv);
+                        if (get_integer(&netns, *argv, 0))
+                                invarg("Invalid \"netns\" value\n", *argv);
+                        addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_MULTICAST;

-- 
