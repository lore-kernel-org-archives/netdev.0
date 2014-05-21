From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: remove Tx work for ptp
Date: Wed, 21 May 2014 05:01:10 -0700
Message-ID: <1400673673-31626-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3720 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbaEUMBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:44 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The previous removal of the PTP Tx work functionality was
incomplete as noted by Jake Keller. This removal allows
us to rely on the Tx timesync interrupt.

CC: Jacob Keller <jacob.e.keller@intel.com>
Change-ID: Id4faaf275a3688053ebbf07bef08072f9fd11aa9
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 -
 drivers/net/ethernet/intel/i40e/i40e_ptp.c     | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7f3d342..861e1db 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -112,7 +112,6 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("rx_oversize", stats.rx_oversize),
 	I40E_PF_STAT("rx_jabber", stats.rx_jabber),
 	I40E_PF_STAT("VF_admin_queue_requests", vf_aq_requests),
-	I40E_PF_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 	I40E_PF_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
 	/* LPI stats */
 	I40E_PF_STAT("tx_lpi_status", stats.tx_lpi_status),
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 1fedc7a..101f439 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -48,7 +48,6 @@
 					I40E_PRTTSYN_CTL1_TSYNTYPE_SHIFT)
 #define I40E_PRTTSYN_CTL1_TSYNTYPE_V2  (0x2 << \
 					I40E_PRTTSYN_CTL1_TSYNTYPE_SHIFT)
-#define I40E_PTP_TX_TIMEOUT  (HZ * 15)
 
 /**
  * i40e_ptp_read - Read the PHC time from the device
-- 
1.9.0
