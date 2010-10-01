From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 1/2] [PATCH 1/2] Slightly simplify options conflicts logic
Date: Fri, 01 Oct 2010 23:40:42 +0900
Message-ID: <20101001144126.520973076@akiko.akashicho.tokyo.vergenet.net>
References: <20101001144041.414393254@akiko.akashicho.tokyo.vergenet.net>
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55341 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756992Ab0JAOpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 10:45:50 -0400
Content-Disposition: inline; filename=0001-Slightly-simplify-options-conflicts-logic.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/ipvsadm.c b/ipvsadm.c
index 76ec7c4..1ac6c7f 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -763,11 +763,9 @@ static int process_options(int argc, char **argv, int reading_stdin)
 
 	switch (ce.cmd) {
 	case CMD_LIST:
-		if ((options & OPT_CONNECTION ||
-		     options & OPT_TIMEOUT || options & OPT_DAEMON) &&
-		    (options & OPT_STATS ||
-		     options & OPT_PERSISTENTCONN ||
-		     options & OPT_RATE || options & OPT_THRESHOLDS))
+		if (options & (OPT_CONNECTION|OPT_TIMEOUT|OPT_DAEMON) &&
+		    options & (OPT_STATS|OPT_PERSISTENTCONN|
+			       OPT_RATE|OPT_THRESHOLDS))
 			fail(2, "options conflicts in the list command");
 
 		if (options & OPT_CONNECTION)
-- 
1.7.1


