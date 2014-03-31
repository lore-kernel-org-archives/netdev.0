From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] ixgbe: remove redundant if clause from PTP work
Date: Mon, 31 Mar 2014 16:34:48 -0700
Message-ID: <1396308899-20926-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42191 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbaCaXgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:06 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

ptp_tx_skb is always set before work is scheduled,
work is cancelled before ptp_tx_skb is set to NULL.
PTP work cannot ever see ptp_tx_skb set to NULL.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 44ac9ae..8b527d7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -512,10 +512,6 @@ static void ixgbe_ptp_tx_hwtstamp_work(struct work_struct *work)
 					      IXGBE_PTP_TX_TIMEOUT);
 	u32 tsynctxctl;
 
-	/* we have to have a valid skb */
-	if (!adapter->ptp_tx_skb)
-		return;
-
 	if (timeout) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
-- 
1.9.0
