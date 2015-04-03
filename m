From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: fix invalid void return in FCoE code
Date: Fri,  3 Apr 2015 05:04:49 -0700
Message-ID: <1428062698-16180-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10571 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbbDCMFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:34 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

A function was calling i40e_tx_map with return, but tx_map returns
void, and the caller returns void, so just drop the return, and
everything is good.

Change-ID: I53fc676d517864761e7cbb8ca83f1ef0c15b1f8f
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 1ca4845..1803afe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1306,8 +1306,7 @@ static void i40e_fcoe_tx_map(struct i40e_ring *tx_ring,
 	/* MACLEN is ether header length in words not bytes */
 	td_offset |= (maclen >> 1) << I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
 
-	return i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
-			   td_cmd, td_offset);
+	i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len, td_cmd, td_offset);
 }
 
 /**
-- 
1.9.3
