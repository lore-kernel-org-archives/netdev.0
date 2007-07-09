From: akpm@linux-foundation.org
Subject: [patch 4/7] sundance: PHY address form 0, only for device ID 0x0200 (IP100A) (20070605)
Date: Mon, 09 Jul 2007 11:50:21 -0700
Message-ID: <200707091850.l69IoLU1001685@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesse@icplus.com.tw
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42671 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757116AbXGISvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Search PHY address form 0, only for device ID 0x0200 (IP100A).  Other
device are from PHY address 1.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sundance.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff -puN drivers/net/sundance.c~sundance-phy-address-form-0-only-for-device-id-0x0200 drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-phy-address-form-0-only-for-device-id-0x0200
+++ a/drivers/net/sundance.c
@@ -562,7 +562,11 @@ static int __devinit sundance_probe1 (st
 	 * It seems some phys doesn't deal well with address 0 being accessed
 	 * first, so leave address zero to the end of the loop (32 & 31).
 	 */
-	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
+	if (sundance_pci_tbl[np->chip_id].device == 0x0200)
+		phy = 0;
+	else
+		phy = 1;
+	for (; phy <= 32 && phy_idx < MII_CNT; phy++) {
 		int phyx = phy & 0x1f;
 		int mii_status = mdio_read(dev, phyx, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
_
