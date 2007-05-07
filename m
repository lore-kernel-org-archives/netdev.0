From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] skge: allow WOL except for known broken chips
Date: Mon, 7 May 2007 11:01:55 -0700
Message-ID: <20070507110155.2063c74d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51093 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965985AbXEGSFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 14:05:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wake On Lan works correctly on Yukon-FE and other variants.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a

---
 drivers/net/skge.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-07 10:04:06.000000000 -0700
+++ sky2-2.6.21/drivers/net/skge.c	2007-05-07 10:04:47.000000000 -0700
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
