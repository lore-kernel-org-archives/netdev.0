From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 16/22] e1000: Rewrite parm handling code to warn when forcing autoneg to gig only.
Date: Fri, 08 Dec 2006 15:03:20 -0800
Message-ID: <20061208230320.30109.51480.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4392 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761263AbWLHWxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:55 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_param.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index cf2a279..f8862e2 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -760,22 +760,13 @@ e1000_check_copper_options(struct e1000_
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
