From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/6] igb: misc cleanup to combine one if statement
	and set last_rx
Date: Thu, 12 Feb 2009 20:18:05 -0800
Message-ID: <20090213041804.3848.73723.stgit@lost.foo-projects.org>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:42459
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758776AbZBMES0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 23:18:26 -0500
In-Reply-To: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch combines a pair of if statements into one and adds a line to
update netdev->last_rx.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5a6bcef..712cfd6 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2981,9 +2981,9 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 
 	if (tso)
 		tx_flags |= IGB_TX_FLAGS_TSO;
-	else if (igb_tx_csum_adv(adapter, tx_ring, skb, tx_flags))
-			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				tx_flags |= IGB_TX_FLAGS_CSUM;
+	else if (igb_tx_csum_adv(adapter, tx_ring, skb, tx_flags) &&
+	         (skb->ip_summed == CHECKSUM_PARTIAL))
+		tx_flags |= IGB_TX_FLAGS_CSUM;
 
 	igb_tx_queue_adv(adapter, tx_ring, tx_flags,
 			 igb_tx_map_adv(adapter, tx_ring, skb, first),
@@ -3886,6 +3886,7 @@ send_up:
 
 		igb_receive_skb(rx_ring, staterr, rx_desc, skb);
 
+		netdev->last_rx = jiffies;
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
 

