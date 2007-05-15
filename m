From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] skge: allow WOL except for known broken chips
Date: Tue, 15 May 2007 15:08:22 -0700
Message-ID: <20070515220903.433419770@linux-foundation.org>
References: <20070515220821.676720721@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59348 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756534AbXEOWT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:19:27 -0400
Content-Disposition: inline; filename=skge-wol-chips
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wake On Lan works correctly on Yukon-FE and other variants.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a

---
 drivers/net/skge.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- linux-2.6.21.y.orig/drivers/net/skge.c	2007-05-10 12:10:38.000000000 -0700
+++ linux-2.6.21.y/drivers/net/skge.c	2007-05-10 13:26:26.000000000 -0700
@@ -135,10 +135,13 @@ static void skge_get_regs(struct net_dev
 /* Wake on Lan only supported on Yukon chips with rev 1 or above */
 static u32 wol_supported(const struct skge_hw *hw)
 {
-	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev != 0)
-		return WAKE_MAGIC | WAKE_PHY;
-	else
+	if (hw->chip_id == CHIP_ID_GENESIS)
 		return 0;
+
+	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev == 0)
+		return 0;
+
+	return WAKE_MAGIC | WAKE_PHY;
 }
 
 static u32 pci_wake_enabled(struct pci_dev *dev)

--
Stephen Hemminger <shemminger@linux-foundation.org>

