From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 21/31] [DCCP]: Always use debug-toggle parameters
Date: Tue, 20 Mar 2007 20:15:59 -0300
Message-ID: <20070320231559.GJ17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:39497 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274AbXCTXQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:16:04 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66936wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:16:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently debugging output (when configured) is automatically enabled when
DCCP modules are compiled into the kernel rather than built as loadable modules.
This is not necessary, since the module parameters in this case become kernel
commandline parameters, e.g. DCCP or CCID3 debug output can be enabled for a
static build by appending the following at the boot prompt:

	dccp.dccp_debug=1 	dccp_ccid3.ccid3_debug=1

This patch therefore does away with the more complicated way of always enabling
debug output for static builds

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 2c5be61..a1768f5 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -31,13 +31,9 @@
 					      __stringify(cond));          \
 			     } while (0)
 
-#ifdef MODULE
 #define DCCP_PRINTK(enable, fmt, args...)	do { if (enable)	     \
 							printk(fmt, ##args); \
 						} while(0)
-#else
-#define DCCP_PRINTK(enable, fmt, args...)	printk(fmt, ##args)
-#endif
 #define DCCP_PR_DEBUG(enable, fmt, a...)	DCCP_PRINTK(enable, KERN_DEBUG \
 						  "%s: " fmt, __FUNCTION__, ##a)
 
-- 
1.5.0.3

