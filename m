From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/3] net: fsl: Allow most drivers to be built with COMPILE_TEST
Date: Tue, 15 Nov 2016 16:40:33 -0800
Message-ID: <20161116004037.20941-2-f.fainelli@gmail.com>
References: <20161116004037.20941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35980 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751481AbcKPAkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:40:45 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so13066048pgx.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:40:44 -0800 (PST)
In-Reply-To: <20161116004037.20941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are only a handful of Freescale Ethernet drivers that don't
actually build with COMPILE_TEST:

* FEC, for which we would need to define a default register layout if no
  supported architecture is defined

* UCC_GETH which depends on PowerPC cpm.h header (which could be moved
  to a generic location)

We need to fix an unmet dependency to get there though:
warning: (FSL_XGMAC_MDIO) selects OF_MDIO which has unmet direct
dependencies (OF && PHYLIB)

which would result in CONFIG_OF_MDIO=[ym] without CONFIG_OF to be set.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index d1ca45fbb164..0df5835d8b94 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -8,7 +8,7 @@ config NET_VENDOR_FREESCALE
 	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
 		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM) || \
-		   ARCH_LAYERSCAPE
+		   ARCH_LAYERSCAPE || COMPILE_TEST
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
@@ -65,6 +65,7 @@ config FSL_PQ_MDIO
 config FSL_XGMAC_MDIO
 	tristate "Freescale XGMAC MDIO"
 	select PHYLIB
+	depends on OF
 	select OF_MDIO
 	---help---
 	  This driver supports the MDIO bus on the Fman 10G Ethernet MACs, and
-- 
2.9.3
