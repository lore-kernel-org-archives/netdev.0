From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Report MDI-X status for twisted-pair interfaces
Date: Tue, 01 Dec 2009 16:00:30 +0000
Message-ID: <1259683230.2831.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Chaitanya Lala <clala@riverbed.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20594 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbZLAQAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:00:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch by Chaitanya Lala <clala@riverbed.com>.

The MDI-X status can be a useful tool for diagnosing network
connectivity issues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 827f16c..df02e91 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1018,6 +1018,22 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	fprintf(stdout, "	Auto-negotiation: %s\n",
 		(ep->autoneg == AUTONEG_DISABLE) ?
 		"off" : "on");
+
+	if (ep->port == PORT_TP) {
+		fprintf(stdout, "	MDI-X: ");
+		switch (ep->eth_tp_mdix) {
+		case ETH_TP_MDI:
+			fprintf(stdout, "off\n");
+			break;
+		case ETH_TP_MDI_X:
+			fprintf(stdout, "on\n");
+			break;
+		default:
+			fprintf(stdout, "Unknown\n");
+			break;
+		}
+	}
+
 	return 0;
 }
 
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

