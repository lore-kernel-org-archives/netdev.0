From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH] sundance: PHY address form 0, only for device ID 0x0200
	(IP100A)
Date: Mon, 04 Jun 2007 17:04:39 -0400
Message-ID: <1180991079.15274.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr46.hinet.net ([168.95.4.146]:48303 "EHLO msr46.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbXFDJIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 05:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Change Logs:
Search PHY address form 0, only for device ID 0x0200 (IP100A). Other device are from PHY address 1.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
---

 drivers/net/sundance.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

5724a72722dfc9cafbb8f273cb82dbf577bd9ad0
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index e1f912d..914ab29 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -562,7 +562,9 @@ #endif
 	 * It seems some phys doesn't deal well with address 0 being accessed
 	 * first, so leave address zero to the end of the loop (32 & 31).
 	 */
-	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
+	if(sundance_pci_tbl[np->chip_id].device == 0x0200) phy = 0;
+	else phy = 1;
+	for (; phy <= 32 && phy_idx < MII_CNT; phy++) {
 		int phyx = phy & 0x1f;
 		int mii_status = mdio_read(dev, phyx, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
-- 
1.3.GIT



