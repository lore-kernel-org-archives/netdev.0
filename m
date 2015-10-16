From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: hisilicon: add OF dependency
Date: Fri, 16 Oct 2015 11:33:49 +0200
Message-ID: <4665385.OoIztz6y5m@wuerfel>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:65109 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbbJPJd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 05:33:59 -0400
In-Reply-To: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HNS MDIO driver fails to build on older ARM machines that are not
yet converted to CONFIG_OF:

drivers/net/ethernet/hisilicon/hns_mdio.c: In function 'hns_mdio_bus_name':
drivers/net/ethernet/hisilicon/hns_mdio.c:405:14: error: 'OF_BAD_ADDR' undeclared (first use in this function)
  u64 taddr = OF_BAD_ADDR;
              ^
drivers/net/ethernet/hisilicon/hns_mdio.c:405:14: note: each undeclared identifier is reported only once for each function it appears in
drivers/net/ethernet/hisilicon/hns_mdio.c:409:11: error: implicit declaration of function 'of_translate_address' [-Werror=implicit-function-declaration]
   taddr = of_translate_address(np, addr);
           ^

This clarifies the dependency to ensure we don't attempt to build these
drivers without CONFIG_OF, but also adds a COMPILE_TEST alternative to
give us better build coverage testing.

Build-tested on x86 as well to ensure this actually works.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 8d12b587809e..f250dec488fd 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_HISILICON
 	bool "Hisilicon devices"
 	default y
-	depends on ARM || ARM64
+	depends on OF && (ARM || ARM64 || COMPILE_TEST)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
