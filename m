From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 3/6] i40e: add GRE tunnel type to csum encoding
Date: Mon, 28 Sep 2015 17:55:31 -0700
Message-ID: <1443488134-36387-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59845 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754735AbbI2Azh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:55:37 -0400
In-Reply-To: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure the Tx checksum encoder knows about GRE protocol and sets the
descriptor flag appropriately.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 4f9ff89..d699fc9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2240,6 +2240,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
+		case IPPROTO_GRE:
+			l4_tunnel = I40E_TXD_CTX_GRE_TUNNELING;
+			break;
 		default:
 			return;
 		}
-- 
2.4.3
