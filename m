From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 11/13] r8169: phy init cleanup
Date: Thu, 18 Oct 2007 23:02:09 +0200
Message-ID: <20071018210208.GL31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36930 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752060AbXJRVGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:06:30 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consistent use of hexadecimal. No change of behavior otherwise.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index cb7bb7f..3680ee7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1215,9 +1215,9 @@ static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 	}, *p = phy_magic;
 	unsigned int i;
 
-	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
-	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
-	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
+	mdio_write(ioaddr, 0x1f, 0x0001);		//w 31 2 0 1
+	mdio_write(ioaddr, 0x15, 0x1000);		//w 21 15 0 1000
+	mdio_write(ioaddr, 0x18, 0x65c7);		//w 24 15 0 65c7
 	rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
 
 	for (i = 0; i < ARRAY_SIZE(phy_magic); i++, p++) {
@@ -1230,14 +1230,18 @@ static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 1); //w 4 11 11 1
 		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0); //w 4 11 11 0
 	}
-	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
+	mdio_write(ioaddr, 0x1f, 0x0000); //w 31 2 0 0
 }
 
 static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 {
-	mdio_write(ioaddr, 31, 0x0002);
-	mdio_write(ioaddr,  1, 0x90d0);
-	mdio_write(ioaddr, 31, 0x0000);
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0002 },
+		{ 0x01, 0x90d0 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
 static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
-- 
1.5.2.4

