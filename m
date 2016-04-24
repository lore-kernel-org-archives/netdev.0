From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Sun, 24 Apr 2016 20:25:23 +0300
Message-ID: <16806435.OmqP10ba8M@wasted.cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: arnd@arndb.de
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34558 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbcDXRZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:25:27 -0400
Received: by mail-lb0-f179.google.com with SMTP id b1so58262953lbi.1
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:25:26 -0700 (PDT)
In-Reply-To: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann asked that get_phy_device() returns either NULL or the error
value,  not both on error.  Do as he said, return ERR_PTR(-ENODEV) instead
of NULL when the PHY ID registers read as  all ones.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/phy_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -529,7 +529,7 @@ struct phy_device *get_phy_device(struct
 
 	/* If the phy_id is mostly Fs, there is no device there */
 	if ((phy_id & 0x1fffffff) == 0x1fffffff)
-		return NULL;
+		return ERR_PTR(-ENODEV);
 
 	return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
 }
