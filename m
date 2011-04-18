From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/42] atlx: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:33:04 -0700 (PDT)
Message-ID: <20110417.173304.260085835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab1DRAdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:39 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E198C24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'tpc' is set but unused in atl1_intr_tx().
Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/atlx/atl1.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 98334a1..dffa691 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2074,9 +2074,6 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
 
 	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
-		struct tx_packet_desc *tpd;
-
-		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
 		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
 		if (buffer_info->dma) {
 			pci_unmap_page(adapter->pdev, buffer_info->dma,
-- 
1.7.4.3

