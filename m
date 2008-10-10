From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 02/14] r8169: update phy init parameters
Date: Fri, 10 Oct 2008 23:39:18 +0200
Message-ID: <20081010213918.GB27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, netdev@vger.kernel.org,
	bonbons@linux-vserver.org, ivecera@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40776 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758822AbYJJVl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:41:27 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The modified parameters are synced with Realtek's driver
version 8.006.00.

The change should only be noticeable with some 8168c.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9881563..62e1115 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1379,26 +1379,45 @@ static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0003 },
 		{ 0x12, 0xc096 },
 		{ 0x16, 0x000a },
-		{ 0x1f, 0x0000 }
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+		{ 0x09, 0x2000 },
+		{ 0x09, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0001 },
 		{ 0x12, 0x2300 },
-		{ 0x1f, 0x0003 },
-		{ 0x16, 0x0f0a },
-		{ 0x1f, 0x0000 },
+		{ 0x03, 0x802f },
+		{ 0x02, 0x4f02 },
+		{ 0x01, 0x0409 },
+		{ 0x00, 0xf099 },
+		{ 0x04, 0x9800 },
+		{ 0x04, 0x9000 },
+		{ 0x1d, 0x3d98 },
 		{ 0x1f, 0x0002 },
 		{ 0x0c, 0x7eb8 },
+		{ 0x06, 0x0761 },
+		{ 0x1f, 0x0003 },
+		{ 0x16, 0x0f0a },
 		{ 0x1f, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
-- 
1.5.3.3

