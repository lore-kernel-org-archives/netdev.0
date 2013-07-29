From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: (unknown)
Date: Mon, 29 Jul 2013 15:18:55 +0200
Message-ID: <1375103935-24242-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:52089 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab3G2NTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 09:19:08 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 14:12:58 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 568C517D805D
	for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 14:20:45 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6TDIoF366257094
	for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 13:18:50 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6TDJ0Sm030967
	for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 07:19:01 -0600
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the bridge fdb replace command to replace an
existing entry in the vxlan device driver forwarding data base.
The entry is identified with its unicast mac address and its
corresponding remote destination information is updated.

This is useful for virtual machine migration and replaces the
bridge fdb del and bridge fdb add commands.

It follows the same interface as ip neigh replace commands.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
bridge/fdb.c |    4 +++-
1 files changed, 3 insertions(+), 1 deletions(-)


--- a/bridge/fdb.c	2013-07-10 07:52:18.000000000 +0200
+++ b/bridge/fdb.c	2013-07-29 13:48:33.253679281 +0200
@@ -30,7 +30,7 @@
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | append | del } ADDR dev DEV {self|master} [ temp ]\n"
+	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV {self|master} [ temp ]\n"
 		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
@@ -334,6 +334,8 @@
 			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
 		if (matches(*argv, "append") == 0)
 			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_APPEND, argc-1, argv+1);
+		if (matches(*argv, "replace") == 0)
+			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_REPLACE, argc-1, argv+1);
 		if (matches(*argv, "delete") == 0)
 			return fdb_modify(RTM_DELNEIGH, 0, argc-1, argv+1);
 		if (matches(*argv, "show") == 0 ||
