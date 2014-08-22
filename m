From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] phylib: use MDIO_DEVS[12]
Date: Fri, 22 Aug 2014 23:56:47 +0400
Message-ID: <1920521.UOn8o4CGAS@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:61977 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbaHVT4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 15:56:51 -0400
Received: by mail-la0-f44.google.com with SMTP id el20so10713744lab.3
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 12:56:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bare register numbers are used despite <uapi/linux/mdio.h> has MDIO_DEVS[12]
#define'd for those.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net-next.git' repo.

 drivers/net/phy/phy_device.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -230,13 +230,13 @@ static int get_phy_c45_ids(struct mii_bu
 	for (i = 1;
 	     i < num_ids && c45_ids->devices_in_package == 0;
 	     i++) {
-		reg_addr = MII_ADDR_C45 | i << 16 | 6;
+		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
 		c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
 
-		reg_addr = MII_ADDR_C45 | i << 16 | 5;
+		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS1;
 		phy_reg = mdiobus_read(bus, addr, reg_addr);
 		if (phy_reg < 0)
 			return -EIO;
