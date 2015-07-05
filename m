From: Rob Herring <robh@kernel.org>
Subject: [PATCH] net: phy: add dependency on HAS_IOMEM to MDIO_BUS_MUX_MMIOREG
Date: Sun,  5 Jul 2015 12:16:27 -0500
Message-ID: <1436116587-1982-1-git-send-email-robh@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rob Herring <robh@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:32899 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbGERRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 13:17:06 -0400
Received: by ykeo3 with SMTP id o3so9991847yke.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 10:17:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On UML builds, mdio-mux-mmioreg.c fails to compile:

drivers/net/phy/mdio-mux-mmioreg.c:50:3: error: implicit declaration of=
 function =E2=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-declar=
ation]
drivers/net/phy/mdio-mux-mmioreg.c:63:3: error: implicit declaration of=
 function =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declar=
ation]

This is due to CONFIG_OF now being user selectable. Add a dependency on
HAS_IOMEM to fix this.

Signed-off-by: Rob Herring <robh@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index cf18940..cb86d7a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -191,7 +191,7 @@ config MDIO_BUS_MUX_GPIO
=20
 config MDIO_BUS_MUX_MMIOREG
 	tristate "Support for MMIO device-controlled MDIO bus multiplexers"
-	depends on OF_MDIO
+	depends on OF_MDIO && HAS_IOMEM
 	select MDIO_BUS_MUX
 	help
 	  This module provides a driver for MDIO bus multiplexers that
--=20
2.1.0
