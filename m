From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: HNS: fix MDIO dependencies
Date: Fri, 09 Oct 2015 14:53:54 +0200
Message-ID: <8114651.XErShuFr2W@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, Yisen Zhuang <Yisen.Zhuang@huawei.com>,
	Kenneth Lee <liguozhu@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly introduced HNS_MDIO Kconfig symbol selects 'MDIO', but
that is the wrong symbol as the code used by this driver is
provided by PHYLIB rather than the MDIO driver. Also, there is
no need to make this driver user selectable, because it is already
selected by all drivers that need it.

This changes the Kconfig file to select the correct library, and
to make the option silent.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5b904d39406 ("net: add Hisilicon Network Subsystem MDIO support")

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 165b5a8aa2ea..8d12b587809e 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -24,7 +24,6 @@ config HIX5HD2_GMAC
 
 config HIP04_ETH
 	tristate "HISILICON P04 Ethernet support"
-	select PHYLIB
 	select MARVELL_PHY
 	select MFD_SYSCON
 	select HNS_MDIO
@@ -33,8 +32,8 @@ config HIP04_ETH
 	  want to use the internal ethernet then you should answer Y to this.
 
 config HNS_MDIO
-	tristate "Hisilicon HNS MDIO device Support"
-	select MDIO
+	tristate
+	select PHYLIB
 	---help---
 	  This selects the HNS MDIO support. It is needed by HNS_DSAF to access
 	  the PHY
