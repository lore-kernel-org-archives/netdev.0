From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/5] ixgbe: don't use magic size number to assign ptp_caps.name
Date: Thu, 13 Feb 2014 00:00:48 -0800
Message-ID: <1392278450-27062-4-git-send-email-aaron.f.brown@intel.com>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36961 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbaBMIDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 03:03:11 -0500
In-Reply-To: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
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
index 95ed8ea..5697214 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -849,7 +849,9 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X540:
-		snprintf(adapter->ptp_caps.name, 16, "%s", netdev->name);
+		snprintf(adapter->ptp_caps.name,
+			 sizeof(adapter->ptp_caps.name),
+			 "%s", netdev->name);
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 250000000;
 		adapter->ptp_caps.n_alarm = 0;
@@ -863,7 +865,9 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
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
