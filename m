From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] macb: fix mdiobus_scan() error check
Date: Sun, 01 May 2016 01:47:36 +0300
Message-ID: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34115 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbcD3Wrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 18:47:41 -0400
Received: by mail-lf0-f43.google.com with SMTP id j11so175073600lfb.1
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 15:47:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now mdiobus_scan() returns ERR_PTR(-ENODEV) instead of NULL if the PHY
device ID was read as all ones. As this was not  an error before, this
value  should be filtered out now in this driver.

Fixes: b74766a0a0fe ("phylib: don't return NULL from get_phy_device()")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/net/ethernet/cadence/macb.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/cadence/macb.c
===================================================================
--- net-next.orig/drivers/net/ethernet/cadence/macb.c
+++ net-next/drivers/net/ethernet/cadence/macb.c
@@ -458,7 +458,8 @@ static int macb_mii_init(struct macb *bp
 				struct phy_device *phydev;
 
 				phydev = mdiobus_scan(bp->mii_bus, i);
-				if (IS_ERR(phydev)) {
+				if (IS_ERR(phydev) &&
+				    PTR_ERR(phydev) != -ENODEV) {
 					err = PTR_ERR(phydev);
 					break;
 				}
