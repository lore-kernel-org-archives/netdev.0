From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e/i40evf: Move stack var deeper
Date: Wed,  6 Apr 2016 20:29:29 -0700
Message-ID: <1459999779-22254-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9491 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbcDGD3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:44 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

A local variable could move down inside the context where it is used.

Change-ID: I9caba9e1eacf921037077f2665cbce83fd8e95d6
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5d5fa53..76a48e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2408,7 +2408,7 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		unsigned char *hdr;
 	} l4;
 	unsigned char *exthdr;
-	u32 offset, cmd = 0, tunnel = 0;
+	u32 offset, cmd = 0;
 	__be16 frag_off;
 	u8 l4_proto = 0;
 
@@ -2422,6 +2422,7 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	offset = ((ip.hdr - skb->data) / 2) << I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
 
 	if (skb->encapsulation) {
+		u32 tunnel = 0;
 		/* define outer network header type */
 		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
 			tunnel |= (*tx_flags & I40E_TX_FLAGS_TSO) ?
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 04aabc5..d633dcf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1633,7 +1633,7 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		unsigned char *hdr;
 	} l4;
 	unsigned char *exthdr;
-	u32 offset, cmd = 0, tunnel = 0;
+	u32 offset, cmd = 0;
 	__be16 frag_off;
 	u8 l4_proto = 0;
 
@@ -1647,6 +1647,7 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	offset = ((ip.hdr - skb->data) / 2) << I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
 
 	if (skb->encapsulation) {
+		u32 tunnel = 0;
 		/* define outer network header type */
 		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
 			tunnel |= (*tx_flags & I40E_TX_FLAGS_TSO) ?
-- 
2.5.5
