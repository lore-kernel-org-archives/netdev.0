From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] iproute2: Fix usage and man page for 'ip link'
Date: Thu, 06 Oct 2011 16:10:51 -0700
Message-ID: <1317942651.6433.25.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52419 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764Ab1JFXK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 19:10:59 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 6 Oct 2011 17:10:55 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p96NAqNl159642
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 17:10:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p96NAqdD032218
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 17:10:52 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add bridge as a supported type with 'ip link' in usage and all the missing
types in 'ip' man page. Also fixed some typos.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/ip/iplink.c b/ip/iplink.c
index e5325a6..35e6dc6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -43,7 +43,7 @@ static int iplink_have_newlink(void);
 void iplink_usage(void)
 {
 	if (iplink_have_newlink()) {
-		fprintf(stderr, "Usage: ip link add link DEV [ name ] NAME\n");
+		fprintf(stderr, "Usage: ip link add [link DEV] [ name ] NAME\n");
 		fprintf(stderr, "                   [ txqueuelen PACKETS ]\n");
 		fprintf(stderr, "                   [ address LLADDR ]\n");
 		fprintf(stderr, "                   [ broadcast LLADDR ]\n");
@@ -78,7 +78,7 @@ void iplink_usage(void)
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
-		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can }\n");
+		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can | bridge }\n");
 	}
 	exit(-1);
 }
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 27993a4..49d94f5 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -47,7 +47,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 
 .ti -8
 .IR TYPE " := [ "
-.BR vlan " | " maclan " | " can " ]"
+.BR vlan " | " veth " | " vcan " | " dummy " | " ifb " | " macvlan " | " can " | " bridge ]"
 
 .ti -8
 .BI "ip link delete " DEVICE
@@ -989,13 +989,28 @@ Link types:
 
 .in +8
 .B vlan
-- 802.1q tagged virrtual LAN interface
+- 802.1q tagged virtual LAN interface
+.sp
+.B veth
+- Virtual ethernet interface
+.sp
+.B vcan
+- Virtual Local CAN interface
+.sp
+.B dummy
+- Dummy network interface
+.sp
+.B ifb
+- Intermediate Functional Block device
 .sp
 .B macvlan
 - virtual interface base on link layer address (MAC)
 .sp
 .B can
 - Controller Area Network interface
+.sp
+.B bridge
+- Ethernet Bridge device
 .in -8
 
 .SS ip link delete - delete virtual link
