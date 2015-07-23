From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] igb: report unsupported ethtool settings in set_coalesce
Date: Thu, 23 Jul 2015 06:52:32 -0700
Message-ID: <1437659564-48822-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11915 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbbGWNwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:47 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

There are many settings possible using ethtool -C/--coalesce, but not
all of them are supported in igb. Report failure when an unsupported
option is set.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 109cad9..b7b9c67 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2159,6 +2159,27 @@ static int igb_set_coalesce(struct net_device *netdev,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	int i;
 
+	if (ec->rx_max_coalesced_frames ||
+	    ec->rx_coalesce_usecs_irq ||
+	    ec->rx_max_coalesced_frames_irq ||
+	    ec->tx_max_coalesced_frames ||
+	    ec->tx_coalesce_usecs_irq ||
+	    ec->stats_block_coalesce_usecs ||
+	    ec->use_adaptive_rx_coalesce ||
+	    ec->use_adaptive_tx_coalesce ||
+	    ec->pkt_rate_low ||
+	    ec->rx_coalesce_usecs_low ||
+	    ec->rx_max_coalesced_frames_low ||
+	    ec->tx_coalesce_usecs_low ||
+	    ec->tx_max_coalesced_frames_low ||
+	    ec->pkt_rate_high ||
+	    ec->rx_coalesce_usecs_high ||
+	    ec->rx_max_coalesced_frames_high ||
+	    ec->tx_coalesce_usecs_high ||
+	    ec->tx_max_coalesced_frames_high ||
+	    ec->rate_sample_interval)
+		return -ENOTSUPP;
+
 	if ((ec->rx_coalesce_usecs > IGB_MAX_ITR_USECS) ||
 	    ((ec->rx_coalesce_usecs > 3) &&
 	     (ec->rx_coalesce_usecs < IGB_MIN_ITR_USECS)) ||
-- 
2.4.3
