From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] mdio_bus: don't return NULL from mdiobus_scan()
Date: Tue, 03 May 2016 23:14:41 +0300
Message-ID: <4702228.vWmKBZLz6G@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:32973 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756095AbcECUOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:14:45 -0400
Received: by mail-lf0-f47.google.com with SMTP id y84so35974871lfc.0
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 13:14:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've finally noticed that mdiobus_scan() also returns either NULL or error
value on failure.  Return ERR_PTR(-ENODEV) instead of NULL since this is
the  error value  already filtered out by the callers that want to ignore
the  MDIO address scan failure...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/net/phy/mdio_bus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -435,7 +435,7 @@ struct phy_device *mdiobus_scan(struct m
 	err = phy_device_register(phydev);
 	if (err) {
 		phy_device_free(phydev);
-		return NULL;
+		return ERR_PTR(-ENODEV);
 	}
 
 	return phydev;
