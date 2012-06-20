From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] igb: Add switch case for supported hardware to igb_ptp_remove.
Date: Wed, 20 Jun 2012 01:44:57 -0700
Message-ID: <1340181903-16382-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31665 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763Ab2FTIpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:07 -0400
In-Reply-To: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

PTP initialization is only done on supported parts, so remove needs
same checks or it will cause crashes on systems with igb devices that
don't support PTP.  This patch adds those checks to the exit function.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index d5ee7fa..c846ea9 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -330,7 +330,17 @@ void igb_ptp_init(struct igb_adapter *adapter)
 
 void igb_ptp_remove(struct igb_adapter *adapter)
 {
-	cancel_delayed_work_sync(&adapter->overflow_work);
+	switch (adapter->hw.mac.type) {
+	case e1000_i211:
+	case e1000_i210:
+	case e1000_i350:
+	case e1000_82580:
+	case e1000_82576:
+		cancel_delayed_work_sync(&adapter->overflow_work);
+		break;
+	default:
+		return;
+	}
 
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
-- 
1.7.10.2
