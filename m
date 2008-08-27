From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 5/6] dccp: Toggle debug output without module unloading
Date: Wed, 27 Aug 2008 07:35:24 +0200
Message-ID: <1219815325-13778-6-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
 <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-5-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46922 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752538AbYH0Ffm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 01:35:42 -0400
In-Reply-To: <1219815325-13778-5-git-send-email-gerrit@erg.abdn.ac.uk>
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

The last is not very useful yet, since no code at the moment calls
the tfrc_debug() macro.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c    |    2 +-
 net/dccp/ccids/ccid3.c    |    2 +-
 net/dccp/ccids/lib/tfrc.c |    2 +-
 net/dccp/proto.c          |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -783,7 +783,7 @@ static struct ccid_operations ccid2 = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-module_param(ccid2_debug, bool, 0444);
+module_param(ccid2_debug, bool, 0644);
 MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
 #endif
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -963,7 +963,7 @@ static struct ccid_operations ccid3 = {
 };
 
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
@@ -1030,7 +1030,7 @@ MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 int dccp_debug;
-module_param(dccp_debug, bool, 0444);
+module_param(dccp_debug, bool, 0644);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
 EXPORT_SYMBOL_GPL(dccp_debug);
