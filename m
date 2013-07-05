From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 1/2] iproute2 vxlan documentation update for bridge command
Date: Fri,  5 Jul 2013 09:08:50 +0200
Message-ID: <1373008131-8057-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:40813 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab3GEHJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 03:09:04 -0400
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Fri, 5 Jul 2013 08:03:24 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6681917D8025
	for <netdev@vger.kernel.org>; Fri,  5 Jul 2013 08:10:27 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6578iic57671752
	for <netdev@vger.kernel.org>; Fri, 5 Jul 2013 07:08:44 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6578sN0009155
	for <netdev@vger.kernel.org>; Fri, 5 Jul 2013 01:08:54 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge fdb command line help and the bridge.8
man page are outdated in regards to the vxlan support.
The patch updates both the command line help for the
bridge command and its man page.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 bridge/fdb.c      |  4 ++--
 man/man8/bridge.8 | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 62 insertions(+), 6 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 6aa5d0a..591fbbe 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -30,8 +30,8 @@ int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ] [router]\n"
-		        "              [ dst IPADDR] [ vlan VID ]\n"
+	fprintf(stderr, "Usage: bridge fdb { add | append | del } ADDR dev DEV {self|master} [ temp ]\n"
+		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
 	exit(-1);
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 9be0c20..66678b5 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -44,12 +44,20 @@ bridge \- show / manipulate bridge addresses and devices
 .IR DEV " ]"
 
 .ti -8
-.BR "bridge fdb" " { " add " | " del " } "
+.BR "bridge fdb" " { " add " | " append " | " del " } "
 .I LLADDR
 .B  dev
 .IR DEV " { "
 .BR local " | " temp " } { "
-.BR self " } { " embedded " } "
+.BR self " } { " embedded " } { " router " } [ "
+.B  dst
+.IR IPADDR " ] [ "
+.B vni
+.IR VNI " ] ["
+.B port
+.IR PORT " ] ["
+.B via
+.IR DEVICE " ]"
 
 .ti -8
 .BR "bridge fdb" " [ " show " ] [ "
@@ -229,6 +237,7 @@ objects contain known Ethernet addresses on a  link.
 
 .P
 The corresponding commands display fdb entries, add new entries,
+append entries,
 and delete old ones.
 
 .SS bridge fdb add - add a new fdb entry
@@ -236,11 +245,11 @@ and delete old ones.
 This command creates a new fdb entry.
 
 .TP
-.BI "ADDRESS"
+.BI "LLADDR"
 the Ethernet MAC address.
 
 .TP
-.BI dev " NAME"
+.BI dev " DEV"
 the interface to which this address is associated.
 
 .B self
@@ -251,7 +260,54 @@ the interface to which this address is associated.
 - the address is associated with an offloaded fdb
 .sp
 
+.B router
+- the destination address is associated with a router.
+Valid if the referenced device is a VXLAN type device and has
+route shortcircuit enabled.
+.sp
+
 .in -8
+The next command line parameters apply only
+when the specified device
+.I DEV
+is of type VXLAN.
+.TP
+.BI dst " IPADDR"
+the IP address of the destination
+VXLAN tunnel endpoint where the Ethernet MAC ADDRESS resides.
+
+.TP
+.BI vni " VNI"
+the VXLAN VNI Network Identifier (or VXLAN Segment ID)
+to use to connect to the remote VXLAN tunnel endpoint.
+If omitted the value specified at vxlan device creation
+will be used.
+
+.TP
+.BI port " PORT"
+the UDP destination PORT number to use to connect to the
+remote VXLAN tunnel endpoint.
+If omitted the default value is used.
+
+.TP
+.BI via " DEVICE"
+device name of the outgoing interface for the
+VXLAN device driver to reach the
+remote VXLAN tunnel endpoint. 
+
+.SS bridge fdb append - append a forwarding database entry
+This command adds a new fdb entry with an already known
+.IR LLADDR .
+Valid only for multicast link layer addresses.
+The command adds support for broadcast and multicast
+Ethernet MAC addresses.
+The Ethernet MAC address is added multiple times into
+the forwarding database and the vxlan device driver
+sends a copy of the data packet to each entry found.
+
+.PP
+The arguments are the same as with
+.BR "bridge fdb add" ,
 
 .SS bridge fdb delete - delete a forwarding database entry
 This command removes an existing fdb entry.
-- 
1.8.1.4
