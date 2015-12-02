From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40e/i40evf: prefetch skb data on transmit
Date: Wed,  2 Dec 2015 00:25:22 -0800
Message-ID: <1449044735-68599-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13263 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762AbbLBIZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:39 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Issue a prefetch for data early in the transmit path.
This should not be generally needed for Tx traffic, but
it helps immensely for pktgen workloads and should help
for forwarding workloads as well.

Change-ID: Iefee870c20599e0c4240e1d8637e4f16b625f83a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 +++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index dbd2bca..7371df7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2806,6 +2806,9 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	int tsyn;
 	int tso;
 
+	/* prefetch the data, we'll need it later */
+	prefetch(skb->data);
+
 	if (0 == i40e_xmit_descriptor_count(skb, tx_ring))
 		return NETDEV_TX_BUSY;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 23fd112..0f1a4ef 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1993,6 +1993,9 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	u8 hdr_len = 0;
 	int tso;
 
+	/* prefetch the data, we'll need it later */
+	prefetch(skb->data);
+
 	if (0 == i40evf_xmit_descriptor_count(skb, tx_ring))
 		return NETDEV_TX_BUSY;
 
-- 
2.5.0
