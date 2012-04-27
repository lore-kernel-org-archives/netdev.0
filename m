From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 2/4] e1000e: add transmit timestamping support
Date: Fri, 27 Apr 2012 15:04:05 -0400
Message-ID: <1335553447-11964-3-git-send-email-willemb@google.com>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f202.google.com ([209.85.160.202]:43564 "EHLO
	mail-gy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759592Ab2D0TKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 15:10:20 -0400
Received: by ghbz15 with SMTP id z15so117842ghb.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 12:10:19 -0700 (PDT)
In-Reply-To: <1335553447-11964-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 851f793..c5d9ad7 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5150,6 +5150,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	/* if count is 0 then mapping error has occurred */
 	count = e1000_tx_map(tx_ring, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
+		skb_tx_timestamp(skb);
+
 		netdev_sent_queue(netdev, skb->len);
 		e1000_tx_queue(tx_ring, tx_flags, count);
 		/* Make sure there is space in the ring for the next send. */
-- 
1.7.7.3
