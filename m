From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/6 v2] igb: misc cleanup to combine one if statement
Date: Fri, 13 Feb 2009 16:45:17 -0800
Message-ID: <20090214004426.28309.80478.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:47776 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752683AbZBNApm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 19:45:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch combines a pair of if statements into one.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---

 drivers/net/igb/igb_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5a6bcef..6c6866b 100644
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

