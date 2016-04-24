From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 4/5] mdio_bus: get_phy_device() doesn't return NULL anymore
Date: Sun, 24 Apr 2016 20:30:53 +0300
Message-ID: <2703899.TobPpSfS5b@wasted.cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: arnd@arndb.de
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36176 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbcDXRa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:30:57 -0400
Received: by mail-lf0-f49.google.com with SMTP id u64so5401122lff.3
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:30:56 -0700 (PDT)
In-Reply-To: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that get_phy_device() no longer returns NULL on error, we don't need
to check for it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/mdio_bus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -419,7 +419,7 @@ struct phy_device *mdiobus_scan(struct m
 	int err;
 
 	phydev = get_phy_device(bus, addr, false);
-	if (IS_ERR(phydev) || phydev == NULL)
+	if (IS_ERR(phydev))
 		return phydev;
 
 	/*
