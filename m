From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 6/6] dccp: Toggle debug output without module unloading
Date: Tue, 29 Jul 2008 15:06:13 +0100
Message-ID: <1217340373-12620-7-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_ccid3_sender_side_updates_last_batch>
 <1217340373-12620-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-6-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36141 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756491AbYG2OG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 10:06:29 -0400
In-Reply-To: <1217340373-12620-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sets the sysfs permissions so that root can toggle the `debug'
parameter available for nearly every DCCP module. This is useful
since there are various module inter-dependencies. The debug flag
can now be toggled at runtime using

  echo 1 > /sys/module/dccp/parameters/dccp_debug
  echo 1 > /sys/module/dccp_ccid2/parameters/ccid2_debug
  echo 1 > /sys/module/dccp_ccid3/parameters/ccid3_debug
  echo 1 > /sys/module/dccp_tfrc_lib/parameters/tfrc_debug

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c    |    2 +-
 net/dccp/ccids/ccid3.c    |    2 +-
 net/dccp/ccids/lib/tfrc.c |    2 +-
 net/dccp/proto.c          |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -661,7 +661,7 @@ static struct ccid_operations ccid2 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-module_param(ccid2_debug, bool, 0444);
+module_param(ccid2_debug, bool, 0644);
 MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
 #endif
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -790,7 +790,7 @@ module_param(do_osc_prev, bool, 0644);
 MODULE_PARM_DESC(do_osc_prev, "Use Oscillation Prevention (RFC 3448, 4.5)");
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-module_param(ccid3_debug, bool, 0444);
+module_param(ccid3_debug, bool, 0644);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 #endif
 
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -10,7 +10,7 @@
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
 int tfrc_debug;
-module_param(tfrc_debug, bool, 0444);
+module_param(tfrc_debug, bool, 0644);
 MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
 #endif
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1092,7 +1092,7 @@ MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 int dccp_debug;
-module_param(dccp_debug, bool, 0444);
+module_param(dccp_debug, bool, 0644);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
 EXPORT_SYMBOL_GPL(dccp_debug);
-- 
1.5.5

