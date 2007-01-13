From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/8] e1000: simplify case handling gigabit at half duplex
Date: Fri, 12 Jan 2007 16:37:41 -0800
Message-ID: <20070113003741.16816.82031.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1195 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161174AbXAMAyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:11 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remvoe duplicate code handling erraneous user supplied wrong case
of gigabit speed with half duplex.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_param.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index cf2a279..f8862e2 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -760,22 +760,13 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 	case SPEED_1000:
 		DPRINTK(PROBE, INFO, "1000 Mbps Speed specified without "
 			"Duplex\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at 1000 Mbps "
-			"Full Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
-		break;
+		goto full_duplex_only;
 	case SPEED_1000 + HALF_DUPLEX:
 		DPRINTK(PROBE, INFO,
 			"Half Duplex is not supported at 1000 Mbps\n");
-		DPRINTK(PROBE, INFO,
-			"Using Autonegotiation at 1000 Mbps "
-			"Full Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
-		break;
+		/* fall through */
 	case SPEED_1000 + FULL_DUPLEX:
+full_duplex_only:
 		DPRINTK(PROBE, INFO,
 		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;



---
Auke Kok <auke-jan.h.kok@intel.com>
