From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc3 2/3] sundance: probe PHYs from MII address 0
Date: Tue, 18 Oct 2005 21:31:01 -0400
Message-ID: <10182005213101.12810@bilbo.tuxdriver.com>
References: <10182005213101.12750@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932437AbVJSBeU@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <10182005213101.12750@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Probe for PHYs starting at MII address 0 instead of MII address 1.
This covers the entire range of MII addresses.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/sundance.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -608,7 +608,7 @@ static int __devinit sundance_probe1 (st
 
 	np->phys[0] = 1;		/* Default setting */
 	np->mii_preamble_required++;
-	for (phy = 1; phy < 32 && phy_idx < MII_CNT; phy++) {
+	for (phy = 0; phy < 32 && phy_idx < MII_CNT; phy++) {
 		int mii_status = mdio_read(dev, phy, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
 			np->phys[phy_idx++] = phy;
