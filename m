From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 3/5] atl1: change cmb write threshold
Date: Thu, 19 Jul 2007 18:45:12 -0500
Message-ID: <11848887141326-git-send-email-jacliburn@bellsouth.net>
References: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf17aec.mail.bellsouth.net ([205.152.59.65]:60798 "EHLO
	imf17aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759414AbXGSXpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 19:45:17 -0400
In-Reply-To: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the threshold number of descriptors used to trigger CMB writes.
The vendor reports that under certain conditions this will reduce the
number of unnecessary tx interrupts and improve rx performance.

This change is lifted directly from vendor version 1.2.40.2 of the L1
driver.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 3b8f633..6aa2dc3 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -917,7 +917,10 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	iowrite32(value, hw->hw_addr + REG_DMA_CTRL);
 
 	/* config CMB / SMB */
-	value = hw->cmb_rrd | ((u32) hw->cmb_tpd << 16);
+	value = (hw->cmb_tpd > adapter->tpd_ring.count) ?
+		hw->cmb_tpd : adapter->tpd_ring.count;
+	value <<= 16;
+	value |= hw->cmb_rrd;
 	iowrite32(value, hw->hw_addr + REG_CMB_WRITE_TH);
 	value = hw->cmb_rx_timer | ((u32) hw->cmb_tx_timer << 16);
 	iowrite32(value, hw->hw_addr + REG_CMB_WRITE_TIMER);
-- 
1.5.2.2

