From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 11/11] ixgb: Add prefetch
Date: Fri, 21 Apr 2006 18:00:55 -0700
Message-ID: <20060422010055.24255.71946.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:50817 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750824AbWDVA5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:49 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- This patch is to improve performance by adding prefetch to the ixgb driver
- Add driver comments

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 26cb0d5..98303cb 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -29,6 +29,13 @@
 #include "ixgb.h"
 
 /* Change Log
+ * 1.0.104 10-Jan-2006
+ * - fix for copybreak/recycle
+ * 1.0.103 Oct-3
+ * - suck in some e1000 changes, including copybreak and LLTX
+ * - support for CX4 adapters
+ * 1.0.102 June-20-2005
+ * - add a workaround for a hardware issue when using TSO
  * 1.0.96 04/19/05
  * - Make needlessly global code static -- bunk@stusta.de
  * - ethtool cleanup -- shemminger@osdl.org
@@ -1916,7 +1923,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
 
-		prefetch(skb->data);
+		prefetch(skb->data - NET_IP_ALIGN);
 
 		if(++i == rx_ring->count) i = 0;
 		next_rxd = IXGB_RX_DESC(*rx_ring, i);
@@ -1929,6 +1936,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		next_buffer = &rx_ring->buffer_info[i];
 		next_skb = next_buffer->skb;
 		prefetch(next_skb);
+		prefetch(next_skb->data - NET_IP_ALIGN);
 
 		cleaned = TRUE;
 

