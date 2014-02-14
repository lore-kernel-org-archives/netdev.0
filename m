From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/1] dccp: re-enable debug macro
Date: Thu, 13 Feb 2014 19:02:33 -0700
Message-ID: <20140213190233.0f0889a4@liptov.cs.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spey.erg.abdn.ac.uk ([139.133.204.173]:34814 "EHLO
	spey.erg.abdn.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbaBNCCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 21:02:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp tfrc: revert

This reverts 6aee49c558de (Jan 4, 2014) since the variable tfrc_debug is
referenced by the tfrc_pr_debug(fmt, ...) macro when TFRC debugging is
enabled. If it is enabled, use of the macro produces a compilation error.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc.c |    2 +-
 net/dccp/ccids/lib/tfrc.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -8,7 +8,7 @@
 #include "tfrc.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
-static bool tfrc_debug;
+bool tfrc_debug;
 module_param(tfrc_debug, bool, 0644);
 MODULE_PARM_DESC(tfrc_debug, "Enable TFRC debug messages");
 #endif
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -21,6 +21,7 @@
 #include "packet_history.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
+extern bool tfrc_debug;
 #define tfrc_pr_debug(format, a...)	DCCP_PR_DEBUG(tfrc_debug, format, ##a)
 #else
 #define tfrc_pr_debug(format, a...)
