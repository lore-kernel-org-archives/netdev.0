From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Fix switch on port type
Date: Tue, 01 Dec 2009 16:06:55 +0000
Message-ID: <1259683615.2831.16.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21032 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbZLAQG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:06:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new port type cases in commit 6e0512c 'ethtool: Add Direct Attach
to the available connector ports' were somehow inserted into the
switch on duplex type, not on port type.  Move them to the correct
place.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index df02e91..10dfc80 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -965,12 +965,6 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case DUPLEX_FULL:
 		fprintf(stdout, "Full\n");
 		break;
-	case PORT_DA:
-		fprintf(stdout, "Direct Attach Copper\n");
-		break;
-	case PORT_NONE:
-		fprintf(stdout, "None\n");
-		break;
 	default:
 		fprintf(stdout, "Unknown! (%i)\n", ep->duplex);
 		break;
@@ -993,6 +987,12 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case PORT_FIBRE:
 		fprintf(stdout, "FIBRE\n");
 		break;
+	case PORT_DA:
+		fprintf(stdout, "Direct Attach Copper\n");
+		break;
+	case PORT_NONE:
+		fprintf(stdout, "None\n");
+		break;
 	case PORT_OTHER:
 		fprintf(stdout, "Other\n");
 		break;
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

