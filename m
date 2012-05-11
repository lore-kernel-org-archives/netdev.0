From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: of/phy: fix build error when phylib is built as a module
Date: Fri, 11 May 2012 17:47:01 +0200
Message-ID: <1336751221-19127-1-git-send-email-bjorn@mork.no>
References: <20120510.224352.2149006669429730060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paul.gortmaker@windriver.com, rdunlap@xenotime.net,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, david.daney@cavium.com,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45468 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab2EKPro (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2012 11:47:44 -0400
In-Reply-To: <20120510.224352.2149006669429730060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_OF_MDIO is tristate and will be m if PHYLIB is m.  Use
IS_ENABLED macro to prevent build error:

 ERROR: "of_mdio_find_bus" [drivers/net/phy/mdio-mux.ko] undefined!

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Cc: David Daney <david.daney@cavium.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
I wonder if this could be as banal as this?  Not even build tested...

Should be wrapped into commit 25106022 if it works, to ensure
bisectability.



Bj=C3=B8rn

 drivers/net/phy/mdio_bus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 83d5c9f..683ef1c 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -88,7 +88,7 @@ static struct class mdio_bus_class =3D {
 	.dev_release	=3D mdiobus_release,
 };
=20
-#ifdef CONFIG_OF_MDIO
+#if IS_ENABLED(CONFIG_OF_MDIO)
 /* Helper function for of_mdio_find_bus */
 static int of_mdio_bus_match(struct device *dev, void *mdio_bus_np)
 {
--=20
1.7.10
