From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: systemport: hook SYSTEMPORT driver in the build
Date: Mon, 21 Apr 2014 10:31:33 -0700
Message-ID: <1398101494-27959-4-git-send-email-f.fainelli@gmail.com>
References: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:60602 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbaDURbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:31:48 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so1952015igb.3
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 10:31:47 -0700 (PDT)
In-Reply-To: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hook the Broadcom SYSTEMPORT driver into the build system under the
SYSTEMPORT Kconfig symbol.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig  | 11 +++++++++++
 drivers/net/ethernet/broadcom/Makefile |  1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 85dbddd03722..3e488094b073 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -150,4 +150,15 @@ config BGMAC
 	  In case of using this driver on BCM4706 it's also requires to enable
 	  BCMA_DRIVER_GMAC_CMN to make it work.
 
+config SYSTEMPORT
+	tristate "Broadcom SYSTEMPORT internal MAC support"
+	depends on OF
+	select MII
+	select PHYLIB
+	select FIXED_PHY if SYSTEMPORT=y
+	help
+	  This driver supports the built-in Ethernet MACs found in the
+	  Broadcom BCM7xxx Set Top Box family chipset using an internal
+	  Ethernet switch.
+
 endif # NET_VENDOR_BROADCOM
diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ethernet/broadcom/Makefile
index fd639a0d4c7d..e2a958a657e0 100644
--- a/drivers/net/ethernet/broadcom/Makefile
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_BNX2X) += bnx2x/
 obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BGMAC) += bgmac.o
+obj-$(CONFIG_SYSTEMPORT) += bcmsysport.o
-- 
1.9.1
