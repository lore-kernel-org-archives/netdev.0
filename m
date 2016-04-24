From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/5] xgene: get_phy_device() doesn't return NULL anymore
Date: Sun, 24 Apr 2016 20:27:49 +0300
Message-ID: <73083313.ix2iJdrut5@wasted.cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: f.fainelli@gmail.com, isubramanian@apm.com, kchudgar@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35533 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbcDXR1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:27:52 -0400
Received: by mail-lf0-f44.google.com with SMTP id c126so104618699lfb.2
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:27:52 -0700 (PDT)
In-Reply-To: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that get_phy_device() no longer returns NULL on error, we don't need
to check for it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
===================================================================
--- net-next.orig/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ net-next/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -824,7 +824,7 @@ static int xgene_mdiobus_register(struct
 		return -EINVAL;
 
 	phy = get_phy_device(mdio, phy_id, false);
-	if (!phy || IS_ERR(phy))
+	if (IS_ERR(phy))
 		return -EIO;
 
 	ret = phy_device_register(phy);
