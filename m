From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e/i40evf: make IPv6 ATR code clearer
Date: Wed, 26 Jul 2017 03:31:16 -0700
Message-ID: <20170726103123.76743-8-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43463 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751655AbdGZKeS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:34:18 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This just reorders some local vars and makes the code flow
clearer.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index b936febc315a..c9a149678926 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2451,9 +2451,15 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		hlen = (hdr.network[0] & 0x0F) << 2;
 		l4_proto = hdr.ipv4->protocol;
 	} else {
-		hlen = hdr.network - skb->data;
-		l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
-		hlen -= hdr.network - skb->data;
+		/* find the start of the innermost ipv6 header */
+		unsigned int inner_hlen = hdr.network - skb->data;
+		unsigned int h_offset = inner_hlen;
+
+		/* this function updates h_offset to the end of the header */
+		l4_proto =
+		  ipv6_find_hdr(skb, &h_offset, IPPROTO_TCP, NULL, NULL);
+		/* hlen will contain our best estimate of the tcp header */
+		hlen = h_offset - inner_hlen;
 	}
 
 	if (l4_proto != IPPROTO_TCP)
-- 
2.13.3
