From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 v2] bridge fdb: add 'use' option to set NTF_USE flag in fdb add requests
Date: Thu, 30 Jul 2015 14:37:02 -0700
Message-ID: <1438292222-45993-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: --to=stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32915 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbbG3VhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 17:37:07 -0400
Received: by padck2 with SMTP id ck2so29384080pad.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 14:37:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This is similar to command options corresponding to other NTF_* flags
already exposed to the user space (examples self/master).

Also updates bridge man page (The man page patch also includes
a fix to the 'self' entry and documents 'master' for fdb entries)

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
v1-v2 : fixed usage

 bridge/fdb.c      |    7 +++++--
 man/man8/bridge.8 |   15 ++++++++++++---
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 278e55f..bd7e4f9 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -31,8 +31,9 @@ static unsigned int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV {self|master} [ temp ]\n"
-		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
+	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace ADDR dev DEV\n"
+			"              [ self ] [ master ] [ use ] [ router ]\n"
+			"              [ local | temp ] [ dst IPADDR ] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
 	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ brport DEV ]\n");
 	exit(-1);
@@ -305,6 +306,8 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 				duparg2("vlan", *argv);
 			NEXT_ARG();
 			vid = atoi(*argv);
+		} else if (matches(*argv, "use") == 0) {
+			req.ndm.ndm_flags |= NTF_USE;
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 4135d01..6796e15 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -53,8 +53,8 @@ bridge \- show / manipulate bridge addresses and devices
 .I LLADDR
 .B  dev
 .IR DEV " { "
-.BR local " | " temp " } { "
-.BR self " } { " router " } [ "
+.BR local " | " temp " } [ "
+.BR self " ] [ " master " ] [ " router " ] [ " use " ] [ "
 .B  dst
 .IR IPADDR " ] [ "
 .B vni
@@ -323,7 +323,11 @@ the Ethernet MAC address.
 the interface to which this address is associated.
 
 .B self
-- the address is associated with a software fdb (default)
+- the address is associated with the port drivers fdb. Usually hardware.
+.sp
+
+.B master
+- the address is associated with master devices fdb. Usually software (default).
 .sp
 
 .B router
@@ -332,6 +336,11 @@ Valid if the referenced device is a VXLAN type device and has
 route shortcircuit enabled.
 .sp
 
+.B use
+- the address is in use. User space can use this option to
+indicate to the kernel that the fdb entry is in use.
+.sp
+
 .in -8
 The next command line parameters apply only
 when the specified device
-- 
1.7.10.4
