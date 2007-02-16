From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/3] e1000: fix shared interrupt warning message
Date: Fri, 16 Feb 2007 14:39:26 -0800
Message-ID: <20070216223926.26963.52634.stgit@gitlost.site>
References: <20070216223913.26963.76602.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Garzik, Jeff" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1345 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946091AbXBPWZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 17:25:08 -0500
In-Reply-To: <20070216223913.26963.76602.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000/e1000_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 619c892..f293690 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1417,10 +1417,6 @@ e1000_open(struct net_device *netdev)
 	if ((err = e1000_setup_all_rx_resources(adapter)))
 		goto err_setup_rx;
 
-	err = e1000_request_irq(adapter);
-	if (err)
-		goto err_req_irq;
-
 	e1000_power_up_phy(adapter);
 
 	if ((err = e1000_up(adapter)))
@@ -1431,6 +1427,10 @@ e1000_open(struct net_device *netdev)
 		e1000_update_mng_vlan(adapter);
 	}
 
+	err = e1000_request_irq(adapter);
+	if (err)
+		goto err_req_irq;
+
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now open */
 	if (adapter->hw.mac_type == e1000_82573 &&
@@ -1439,10 +1439,10 @@ e1000_open(struct net_device *netdev)
 
 	return E1000_SUCCESS;
 
+err_req_irq:
+	e1000_down(adapter);
 err_up:
 	e1000_power_down_phy(adapter);
-	e1000_free_irq(adapter);
-err_req_irq:
 	e1000_free_all_rx_resources(adapter);
 err_setup_rx:
 	e1000_free_all_tx_resources(adapter);



---
Auke Kok <auke-jan.h.kok@intel.com>
