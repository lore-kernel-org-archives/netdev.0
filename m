From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/4] net: systemport: hook SYSTEMPORT driver in the build
Date: Thu, 24 Apr 2014 18:08:59 -0700
Message-ID: <1398388140-8003-4-git-send-email-f.fainelli@gmail.com>
References: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35095 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbaDYBJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 21:09:26 -0400
Received: by mail-pb0-f53.google.com with SMTP id jt11so845745pbb.40
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 18:09:26 -0700 (PDT)
In-Reply-To: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
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
