From: akpm@osdl.org
Subject: [patch 08/11] Signedness issue in drivers/net/phy/phy_device.c
Date: Mon, 25 Sep 2006 16:39:22 -0700
Message-ID: <200609252339.k8PNdMsp002651@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, snakebyte@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13748 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751715AbWIYXj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:29 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Sesterhenn <snakebyte@gmx.de>

While checking gcc 4.1 -Wextra warnings, I stumbled across the following
two warnings:

drivers/net/phy/phy_device.c:528: warning: comparison of unsigned expression < 0 is always false
drivers/net/phy/phy_device.c:546: warning: comparison of unsigned expression < 0 is always false

Since phy_read() returns an integer and can return negative values, it seems
to me the best way to get proper error handling working again is to make val
an int.  Currently it is an u32, so the < 0 check always fails.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/phy/phy_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/phy/phy_device.c~signedness-issue-in-drivers-net-phy-phy_devicec drivers/net/phy/phy_device.c
--- a/drivers/net/phy/phy_device.c~signedness-issue-in-drivers-net-phy-phy_devicec
+++ a/drivers/net/phy/phy_device.c
@@ -522,7 +522,7 @@ EXPORT_SYMBOL(genphy_read_status);
 
 static int genphy_config_init(struct phy_device *phydev)
 {
-	u32 val;
+	int val;
 	u32 features;
 
 	/* For now, I'll claim that the generic driver supports
_
