From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] igb: specify phc_index of 82575 for get_ts_info
Date: Fri, 21 Mar 2014 05:10:04 -0700
Message-ID: <1395403806-29302-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ken ICHIKAWA <ichikawa.ken@jp.fujitsu.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15007 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965526AbaCUMKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:15 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken ICHIKAWA <ichikawa.ken@jp.fujitsu.com>

82575 has only software timestamping capability and it has
no PTP Hardware Clocks. Therefore, -1 has to be specified
to the phc_index for ethtool's get_ts_info, otherwise a wrong
value will be set to the phc_index.

v2: move the if (adapter->ptp_clock) section specifying phc_index
    to above the switch statement as suggested by Matthew Vick.
    adapter->ptpclock will always be NULL for 82575.

Signed-off-by: Ken ICHIKAWA <ichikawa.ken@jp.fujitsu.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index d5c3e65..e5570ac 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2353,6 +2353,11 @@ static int igb_get_ts_info(struct net_device *dev,
 {
 	struct igb_adapter *adapter = netdev_priv(dev);
 
+	if (adapter->ptp_clock)
+		info->phc_index = ptp_clock_index(adapter->ptp_clock);
+	else
+		info->phc_index = -1;
+
 	switch (adapter->hw.mac.type) {
 	case e1000_82575:
 		info->so_timestamping =
@@ -2374,11 +2379,6 @@ static int igb_get_ts_info(struct net_device *dev,
 			SOF_TIMESTAMPING_RX_HARDWARE |
 			SOF_TIMESTAMPING_RAW_HARDWARE;
 
-		if (adapter->ptp_clock)
-			info->phc_index = ptp_clock_index(adapter->ptp_clock);
-		else
-			info->phc_index = -1;
-
 		info->tx_types =
 			(1 << HWTSTAMP_TX_OFF) |
 			(1 << HWTSTAMP_TX_ON);
-- 
1.8.3.1
