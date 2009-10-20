From: Brice Goglin <brice@myri.com>
Subject: [PATCH][RESEND] myri10ge: improve port type reporting in ethtool
Date: Tue, 20 Oct 2009 08:21:54 +0200
Message-ID: <4ADD5702.80804@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1809 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752541AbZJTGXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2009 02:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve the reporting of myri10ge port type in ethtool,
and update for new boards.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 29c9fe2..5319db9 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.0-1.432"
+#define MYRI10GE_VERSION_STR "1.5.1-1.451"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1623,10 +1623,21 @@ myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 			return 0;
 		}
 	}
-	if (*ptr == 'R' || *ptr == 'Q') {
-		/* We've found either an XFP or quad ribbon fiber */
+	if (*ptr == '2')
+		ptr++;
+	if (*ptr == 'R' || *ptr == 'Q' || *ptr == 'S') {
+		/* We've found either an XFP, quad ribbon fiber, or SFP+ */
 		cmd->port = PORT_FIBRE;
+		cmd->supported |= SUPPORTED_FIBRE;
+		cmd->advertising |= ADVERTISED_FIBRE;
+	} else {
+		cmd->port = PORT_OTHER;
 	}
+	if (*ptr == 'R' || *ptr == 'S')
+		cmd->transceiver = XCVR_EXTERNAL;
+	else
+		cmd->transceiver = XCVR_INTERNAL;
+
 	return 0;
 }
 


