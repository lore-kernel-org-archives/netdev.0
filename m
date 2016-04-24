From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/5] fixed_phy: get_phy_device() doesn't return NULL anymore
Date: Sun, 24 Apr 2016 20:29:23 +0300
Message-ID: <7242612.WszImdz4eS@wasted.cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: arnd@arndb.de
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33248 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbcDXR30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:29:26 -0400
Received: by mail-lb0-f176.google.com with SMTP id jj5so17441337lbc.0
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:29:26 -0700 (PDT)
In-Reply-To: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that get_phy_device() no longer returns NULL on error, we don't need
to check for it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/fixed_phy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/phy/fixed_phy.c
===================================================================
--- net-next.orig/drivers/net/phy/fixed_phy.c
+++ net-next/drivers/net/phy/fixed_phy.c
@@ -328,7 +328,7 @@ struct phy_device *fixed_phy_register(un
 		return ERR_PTR(ret);
 
 	phy = get_phy_device(fmb->mii_bus, phy_addr, false);
-	if (!phy || IS_ERR(phy)) {
+	if (IS_ERR(phy)) {
 		fixed_phy_del(phy_addr);
 		return ERR_PTR(-EINVAL);
 	}
