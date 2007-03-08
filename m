From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: revert bogus BMCR reset
Date: Thu, 8 Mar 2007 23:59:54 +0100
Message-ID: <20070308225954.GA27354@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roman Jarosz <kedgedev@centrum.cz>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43852 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030862AbXCHXFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 18:05:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added during bf793295e1090af84972750898bf8470df5e5419

The current code requests a reset but prohibits autoneg, 1000 Mb/s,
100 Mb/s and full duplex. The 8168 does not like it at all.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 688b64d..521b5f0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -572,8 +572,8 @@ static void rtl8169_xmii_reset_enable(void __iomem *ioaddr)
 {
 	unsigned int val;
 
-	mdio_write(ioaddr, MII_BMCR, BMCR_RESET);
-	val = mdio_read(ioaddr, MII_BMCR);
+	val = mdio_read(ioaddr, MII_BMCR) | BMCR_RESET;
+	mdio_write(ioaddr, MII_BMCR, val & 0xffff);
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
-- 
1.4.4.4

