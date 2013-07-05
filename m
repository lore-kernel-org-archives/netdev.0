From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 2/2] iproute2 vxlan documentation update for ip command
Date: Fri,  5 Jul 2013 09:08:51 +0200
Message-ID: <1373008131-8057-2-git-send-email-tmricht@linux.vnet.ibm.com>
References: <1373008131-8057-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:50276 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab3GEHJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 03:09:02 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Fri, 5 Jul 2013 08:04:16 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id AD7CC1B0805D
	for <netdev@vger.kernel.org>; Fri,  5 Jul 2013 08:08:58 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6578lXS55509070
	for <netdev@vger.kernel.org>; Fri, 5 Jul 2013 07:08:47 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6578vUr009239
	for <netdev@vger.kernel.org>; Fri, 5 Jul 2013 01:08:57 -0600
In-Reply-To: <1373008131-8057-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip link command line help and the ip-link.8.in
man page are outdated in regards to the vxlan support.
The patch updates both the command line help for the
ip command and its man page.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 ip/iplink.c           |  2 +-
 man/man8/ip-link.8.in | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index dc98019..f677329 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -83,7 +83,7 @@ void iplink_usage(void)
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
-		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
+		fprintf(stderr, "TYPE := { vlan | vxlan | veth | vcan | dummy | ifb | macvlan | can |\n");
 		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan }\n");
 	}
 	exit(-1);
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 2e89efe..86e0bc9 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -196,6 +196,91 @@ specifies the number of transmit queues for new device.
 .BI numrxqueues " QUEUE_COUNT "
 specifies the number of receive queues for new device.
 
+.TP
+VXLAN Type Support
+For a link of type 
+.I VXLAN
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE
+.BI type " vxlan " id " ID
+.R " [ "
+.BI dev " PHYS_DEV "
+.R " ] [ "
+.BI group " IPADDR "
+.R " ] [ "
+.BI local " IPADDR "
+.R " ] [ "
+.BI ttl " TTL "
+.R " ] [ "
+.BI tos " TOS "
+.R " ] [ "
+.BI port " MIN MAX "
+.R " ] [ "
+.I "[no]learning "
+.R " ] [ "
+.I "[no]proxy "
+.R " ] [ "
+.I "[no]rsc "
+.R " ] [ "
+.I "[no]l2miss "
+.R " ] [ "
+.I "[no]l3miss "
+.R " ]"
+
+.in +8
+.sp
+.BI  id " VNI "
+- specifies the VXLAN Network Identifer (or VXLAN Segment
+Identifier) to use.
+
+.BI dev " PHYS_DEV"
+- specifies the physical device to use for tunnel endpoint communication.
+
+.sp
+.BI group " IPADDR"
+- specifies the multicast IP address to join.
+
+.sp
+.BI local " IPADDR"
+- specifies the source IP address to use in outgoing packets.
+
+.sp
+.BI ttl " TTL"
+- specifies the TTL value to use in outgoing packets.
+
+.sp
+.BI tos " TOS"
+- specifies the TOS value to use in outgoing packets.
+
+.sp
+.BI port " MIN MAX"
+- specifies the range of port numbers to use as UDP
+source ports to communicate to the remote VXLAN tunnel endpoint.
+
+.sp
+.I [no]learning
+- specifies if unknown source link layer addresses and IP addresses
+are entered into the VXLAN device forwarding database.
+
+.sp
+.I [no]rsc
+- specifies if route short circuit is turned on.
+
+.sp
+.I [no]proxy
+- specifies ARP proxy is turned on.
+
+.sp
+.I [no]l2miss
+- specifies if netlink LLADDR miss notifications are generated.
+
+.sp
+.I [no]l3miss
+- specifies if netlink IP ADDR miss notifications are generated.
+
+.in -8
+
 .SS ip link delete - delete virtual link
 .I DEVICE
 specifies the virtual  device to act operate on.
-- 
1.8.1.4
