From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH] sundance: PHY address form 0, only for device ID 0x0200
	(IP100A) (20070605)
Date: Tue, 05 Jun 2007 09:53:11 -0400
Message-ID: <1181051591.2571.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr43.hinet.net ([168.95.4.143]:45607 "EHLO msr43.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbXFEB4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 21:56:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Change Logs:
Search PHY address form 0, only for device ID 0x0200 (IP100A). Other device are from PHY address 1.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
---

 drivers/net/sundance.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

a093fe5e3e7b9f58458171e481b5096cc1d3abfe
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index e1f912d..23d049d 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -562,7 +562,11 @@ #endif
 	 * It seems some phys doesn't deal well with address 0 being accessed
 	 * first, so leave address zero to the end of the loop (32 & 31).
 	 */
-	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
+	if(sundance_pci_tbl[np->chip_id].device == 0x0200) 
+		phy = 0;
+	else 
+		phy = 1;
+	for (; phy <= 32 && phy_idx < MII_CNT; phy++) {
 		int phyx = phy & 0x1f;
 		int mii_status = mdio_read(dev, phyx, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
-- 
1.3.GIT

