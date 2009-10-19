From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: improve port type reporting in ethtool output
Date: Mon, 19 Oct 2009 07:35:04 +0200
Message-ID: <4ADBFA88.8030300@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1963 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751029AbZJSFg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 01:36:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve the reporting of the port type in ethtool,
update for new boards.

Signed-off-by: Brice Goglin <brice@myri.com>

--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.0-1.432"
+#define MYRI10GE_VERSION_STR "1.5.1-1.450"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1601,6 +1601,8 @@ myri10ge_get_settings(struct net_device *netdev,
struct ethtool_cmd *cmd)
     cmd->autoneg = AUTONEG_DISABLE;
     cmd->speed = SPEED_10000;
     cmd->duplex = DUPLEX_FULL;
+    cmd->supported = SUPPORTED_10000baseT_Full;
+    cmd->advertising = ADVERTISED_10000baseT_Full;
 
     /*
      * parse the product code to deterimine the interface type
@@ -1623,10 +1625,19 @@ myri10ge_get_settings(struct net_device *netdev,
struct ethtool_cmd *cmd)
             return 0;
         }
     }
-    if (*ptr == 'R' || *ptr == 'Q') {
-        /* We've found either an XFP or quad ribbon fiber */
+    if (*ptr == '2')
+        ptr++;
+    if (*ptr == 'R' || *ptr == 'Q' || *ptr == 'S') {
+        /* We've found either an XFP, quad ribbon fiber, or SFP+ */
         cmd->port = PORT_FIBRE;
+        cmd->supported |= SUPPORTED_FIBRE;
+        cmd->advertising |= ADVERTISED_FIBRE;
     }
+    if (*ptr == 'R' || *ptr == 'S')
+        cmd->transceiver = XCVR_EXTERNAL;
+    else
+        cmd->transceiver = XCVR_INTERNAL;
+
     return 0;
 }
 

