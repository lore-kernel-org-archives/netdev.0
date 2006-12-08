From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 19/22] e1000: Don't set tipg (fiber) timings for pci-e adapters to fix fiber output
Date: Fri, 08 Dec 2006 15:03:27 -0800
Message-ID: <20061208230327.30109.61195.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4395 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1947467AbWLHWyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:54:01 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


the driver has (ancient) code for messing with TIPG from the 82542 days.
Unfortunately this code was running on our current adapters and setting
TIPG for fiber to be +1 over the copper value.  This caused 1.45Mpps
to be sent instead of 1.487Mpps.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 34ceff1..1a2b052 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1669,9 +1669,9 @@ e1000_configure_tx(struct e1000_adapter 
 	}
 
 	/* Set the default values for the Tx Inter Packet Gap timer */
-
-	if (hw->media_type == e1000_media_type_fiber ||
-	    hw->media_type == e1000_media_type_internal_serdes)
+	if (adapter->hw.mac_type <= e1000_82547_rev_2 &&
+	    (hw->media_type == e1000_media_type_fiber ||
+	     hw->media_type == e1000_media_type_internal_serdes))
 		tipg = DEFAULT_82543_TIPG_IPGT_FIBER;
 	else
 		tipg = DEFAULT_82543_TIPG_IPGT_COPPER;



---
Auke Kok <auke-jan.h.kok@intel.com>
