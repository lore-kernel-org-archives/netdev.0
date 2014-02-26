From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/6] ixgbe: don't use magic size number to assign ptp_caps.name
Date: Tue, 25 Feb 2014 17:58:54 -0800
Message-ID: <1393379938-1415-3-git-send-email-aaron.f.brown@intel.com>
References: <1393379938-1415-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48765 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbaBZCCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 21:02:16 -0500
In-Reply-To: <1393379938-1415-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Rather than using a magic size number, just use sizeof since that will
work and is more robust to future changes.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 5184e2a..9e54fcc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -840,7 +840,9 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X540:
-		snprintf(adapter->ptp_caps.name, 16, "%s", netdev->name);
+		snprintf(adapter->ptp_caps.name,
+			 sizeof(adapter->ptp_caps.name),
+			 "%s", netdev->name);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
@@ -854,7 +856,9 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 		adapter->ptp_caps.enable = ixgbe_ptp_enable;
 		break;
 	case ixgbe_mac_82599EB:
-		snprintf(adapter->ptp_caps.name, 16, "%s", netdev->name);
+		snprintf(adapter->ptp_caps.name,
+			 sizeof(adapter->ptp_caps.name),
+			 "%s", netdev->name);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
-- 
1.8.5.GIT
