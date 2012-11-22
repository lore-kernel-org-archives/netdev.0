From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 9/9] tipc: delete TIPC_ADVANCED Kconfig variable
Date: Thu, 22 Nov 2012 15:59:54 -0500
Message-ID: <1353617994-3962-10-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43260 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932605Ab2KVVAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:16 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There used to be a time when TIPC had lots of Kconfig knobs the
end user could alter, but they have all been made automatic or
obsolete, with the exception of CONFIG_TIPC_PORTS.  This
previously existing set of options was all hidden under the
TIPC_ADVANCED setting, which does not exist in any code, but
only in Kconfig scope.

Having this now, just to hide the one remaining "advanced"
option no longer makes sense.  Remove it.  Also get rid of the
ifdeffery in the TIPC code that allowed for TIPC_PORTS to be
possibly undefined.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Kconfig | 13 +------------
 net/tipc/core.c  |  5 -----
 2 files changed, 1 insertion(+), 17 deletions(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 5854601..bc41bd3 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -20,18 +20,9 @@ menuconfig TIPC
 
 	  If in doubt, say N.
 
-if TIPC
-
-config TIPC_ADVANCED
-	bool "Advanced TIPC configuration"
-	default n
-	help
-	  Saying Y here will open some advanced configuration for TIPC.
-	  Most users do not need to bother; if unsure, just say N.
-
 config TIPC_PORTS
 	int "Maximum number of ports in a node"
-	depends on TIPC_ADVANCED
+	depends on TIPC
 	range 127 65535
 	default "8191"
 	help
@@ -40,5 +31,3 @@ config TIPC_PORTS
 
 	  Setting this to a smaller value saves some memory,
 	  setting it to higher allows for more ports.
-
-endif # TIPC
diff --git a/net/tipc/core.c b/net/tipc/core.c
index bfe8af8..fc05cec 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -42,11 +42,6 @@
 
 #include <linux/module.h>
 
-#ifndef CONFIG_TIPC_PORTS
-#define CONFIG_TIPC_PORTS 8191
-#endif
-
-
 /* global variables used by multiple sub-systems within TIPC */
 int tipc_random __read_mostly;
 
-- 
1.7.12.1
