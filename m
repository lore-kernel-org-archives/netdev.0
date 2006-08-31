From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/7] 8139cp: sync the device private data with its r8169 counterpart
Date: Thu, 31 Aug 2006 22:51:13 +0200
Message-ID: <20060831205113.GD14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60843 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932449AbWHaUwH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:52:07 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct cp_private is reorganized to be more easily compared between the
r8169 and the 8139cp drivers.

The alignment should not be impacted.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

d03d376dd29cae53bf70a21a0c26b306abe37326
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 0725681..9aef517 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -352,23 +352,23 @@ struct cp_private {
 	struct net_device_stats net_stats;
 	struct cp_extra_stats	cp_stats;
 
-	unsigned		rx_tail		____cacheline_aligned;
+	unsigned		rx_head		____cacheline_aligned;
+	unsigned		rx_tail;
 	struct cp_desc		*rx_ring;
 	struct sk_buff		*rx_skb[CP_RX_RING_SIZE];
-	unsigned		rx_buf_sz;
 
 	unsigned		tx_head		____cacheline_aligned;
 	unsigned		tx_tail;
-
 	struct cp_desc		*tx_ring;
 	struct ring_info	tx_skb[CP_TX_RING_SIZE];
-	dma_addr_t		ring_dma;
+
+	unsigned		rx_buf_sz;
+	unsigned		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
 
 #if CP_VLAN_TAG_USED
 	struct vlan_group	*vlgrp;
 #endif
-
-	unsigned int		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
+	dma_addr_t		ring_dma;
 
 	struct mii_if_info	mii_if;
 };
-- 
1.3.1

