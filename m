From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 20/23] e1000: don't strip vlan ID if 8021q claims it
Date: Tue, 19 Sep 2006 10:29:18 -0700
Message-ID: <20060919172918.4605.80549.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:30989 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030347AbWISRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:23 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7a991a4..dc14b98 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1344,8 +1344,12 @@ e1000_close(struct net_device *netdev)
 	e1000_free_all_tx_resources(adapter);
 	e1000_free_all_rx_resources(adapter);
 
+	/* kill manageability vlan ID if supported, but not if a vlan with
+	 * the same ID is registered on the host OS (let 8021q kill it) */
 	if ((adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) {
+			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
+	     !(adapter->vlgrp &&
+			  adapter->vlgrp->vlan_devices[adapter->mng_vlan_id])) {
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 	}
 



---
Auke Kok <auke-jan.h.kok@intel.com>
