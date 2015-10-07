From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-next v2 4/4] drivers/net/ethernet: make ti/cpsw-phy-sel.c explicitly non-modular
Date: Wed, 7 Oct 2015 17:27:46 -0400
Message-ID: <1444253266-22012-5-git-send-email-paul.gortmaker@windriver.com>
References: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Varka Bhadram <varkabhadram@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52792 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbbJGV2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:28:04 -0400
In-Reply-To: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig currently controlling compilation of this code is:

drivers/net/ethernet/ti/Kconfig:config TI_CPSW_PHY_SEL
drivers/net/ethernet/ti/Kconfig:        bool "TI CPSW Switch Phy sel Support"

...meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
driver there is no doubt it is builtin-only.

Since module_platform_driver() uses the same init level priority as
builtin_platform_driver() the init ordering remains unchanged with
this commit.

Also note that MODULE_DEVICE_TABLE is a no-op for non-modular code.

We also delete the MODULE_LICENSE tag etc. since all that information
was (or is now) contained at the top of the file in the comments.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Varka Bhadram <varkabhadram@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index 0ea78326cc21..e9cc61e1ec74 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -2,6 +2,8 @@
  *
  * Copyright (C) 2013 Texas Instruments
  *
+ * Module Author: Mugunthan V N <mugunthanvnm@ti.com>
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * version 2 as published by the Free Software Foundation.
@@ -13,7 +15,7 @@
  */
 
 #include <linux/platform_device.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/of.h>
@@ -173,7 +175,6 @@ static const struct of_device_id cpsw_phy_sel_id_table[] = {
 	},
 	{}
 };
-MODULE_DEVICE_TABLE(of, cpsw_phy_sel_id_table);
 
 static int cpsw_phy_sel_probe(struct platform_device *pdev)
 {
@@ -214,7 +215,4 @@ static struct platform_driver cpsw_phy_sel_driver = {
 		.of_match_table = cpsw_phy_sel_id_table,
 	},
 };
-
-module_platform_driver(cpsw_phy_sel_driver);
-MODULE_AUTHOR("Mugunthan V N <mugunthanvnm@ti.com>");
-MODULE_LICENSE("GPL v2");
+builtin_platform_driver(cpsw_phy_sel_driver);
-- 
2.6.0.rc3
