From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 5/5] of_mdio: get_phy_device() doesn't return NULL anymore
Date: Sun, 24 Apr 2016 20:31:42 +0300
Message-ID: <2718908.IUaySUkXrd@wasted.cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: arnd@arndb.de
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35980 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbcDXRbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:31:45 -0400
Received: by mail-lb0-f177.google.com with SMTP id ys16so67215812lbb.3
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:31:44 -0700 (PDT)
In-Reply-To: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that get_phy_device() no longer returns NULL on error, we don't need
to check for it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/of/of_mdio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -56,7 +56,7 @@ static void of_mdiobus_register_phy(stru
 		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
 	else
 		phy = get_phy_device(mdio, addr, is_c45);
-	if (IS_ERR_OR_NULL(phy))
+	if (IS_ERR(phy))
 		return;
 
 	rc = irq_of_parse_and_map(child, 0);
