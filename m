From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 2/2 V2] iproute2 vxlan documentation update for ip command
Date: Mon,  8 Jul 2013 14:05:43 +0200
Message-ID: <1373285143-21539-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:43377 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770Ab3GHMFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 08:05:53 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Mon, 8 Jul 2013 13:01:29 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4B38D1B0805D
	for <netdev@vger.kernel.org>; Mon,  8 Jul 2013 13:05:50 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r68C5can54460452
	for <netdev@vger.kernel.org>; Mon, 8 Jul 2013 12:05:38 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r68C5n4P001039
	for <netdev@vger.kernel.org>; Mon, 8 Jul 2013 06:05:49 -0600
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
