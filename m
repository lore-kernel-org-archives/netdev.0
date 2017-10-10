From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] e1000e: Fix wrong comment related to link detection
Date: Tue, 10 Oct 2017 10:21:32 -0700
Message-ID: <20171010172139.77914-3-jeffrey.t.kirsher@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11575 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932558AbdJJRWB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:01 -0400
In-Reply-To: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

Reading e1000e_check_for_copper_link() shows that get_link_status is set to
false after link has been detected. Therefore, it stays TRUE until then.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8436c5f2c3e8..ead4c112580e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5074,7 +5074,7 @@ static bool e1000e_has_link(struct e1000_adapter *adapter)
 
 	/* get_link_status is set on LSC (link status) interrupt or
 	 * Rx sequence error interrupt.  get_link_status will stay
-	 * false until the check_for_link establishes link
+	 * true until the check_for_link establishes link
 	 * for copper adapters ONLY
 	 */
 	switch (hw->phy.media_type) {
@@ -5092,7 +5092,7 @@ static bool e1000e_has_link(struct e1000_adapter *adapter)
 		break;
 	case e1000_media_type_internal_serdes:
 		ret_val = hw->mac.ops.check_for_link(hw);
-		link_active = adapter->hw.mac.serdes_has_link;
+		link_active = hw->mac.serdes_has_link;
 		break;
 	default:
 	case e1000_media_type_unknown:
-- 
2.14.2
