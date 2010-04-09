From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: stop cleaning when we reach
	tx_ring->next_to_use
Date: Fri, 09 Apr 2010 13:29:49 -0700
Message-ID: <20100409202917.31293.79618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Terry Loftin <terry.loftin@hp.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:56429 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757088Ab0DIUa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 16:30:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Terry Loftin <terry.loftin@hp.com>

Tx ring buffers after tx_ring->next_to_use are volatile and could
change, possibly causing a crash.  Stop cleaning when we hit
tx_ring->next_to_use.

Signed-off-by: Terry Loftin <terry.loftin@hp.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

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

