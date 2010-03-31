From: Terry Loftin <terry.loftin@hp.com>
Subject: [PATCH 1/1] e1000e:  stop cleaning when we reach tx_ring->next_to_use
Date: Wed, 31 Mar 2010 14:01:52 -0600
Message-ID: <4BB3AA30.3060906@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:36513 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757061Ab0CaUBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:01:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tx ring buffers after tx_ring->next_to_use are volatile and could
change, possibly causing a crash.  Stop cleaning when we hit
tx_ring->next_to_use.

Signed-off-by: Terry Loftin <terry.loftin@hp.com>
---
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e1cceb6..60288e4 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -660,6 +660,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 				i = 0;
 		}

+		if (i == tx_ring->next_to_use)
+			break;
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
 	}
