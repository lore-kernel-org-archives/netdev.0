From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 4/6] net/ethernet: make amd/hplance.c driver explicitly non-modular
Date: Mon, 28 Sep 2015 15:51:28 -0400
Message-ID: <1443469890-19485-5-git-send-email-paul.gortmaker@windriver.com>
References: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-m68k@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Kconfig for this driver is currently:

config HPLANCE
        bool "HP on-board LANCE support"

...meaning that it currently is not being built as a module by
anyone.  Lets remove the modular and unused code here, so that
when reading the driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.

We don't swap module.h for init.h since this file has init.h already.

We move the information from the MODULE_LICENSE tag to the top of the
file in this case, since it is not duplicating similar information
already there.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/amd/hplance.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 6c9de117ffc6..fa9397508a79 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -3,9 +3,9 @@
  * Copyright (C) 05/1998 Peter Maydell <pmaydell@chiark.greenend.org.uk>
  * Based on the Sun Lance driver and the NetBSD HP Lance driver
  * Uses the generic 7990.c LANCE code.
+ * License: GPL
  */
 
-#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
@@ -220,13 +220,4 @@ static int __init hplance_init_module(void)
 {
 	return dio_register_driver(&hplance_driver);
 }
-
-static void __exit hplance_cleanup_module(void)
-{
-	dio_unregister_driver(&hplance_driver);
-}
-
-module_init(hplance_init_module);
-module_exit(hplance_cleanup_module);
-
-MODULE_LICENSE("GPL");
+device_initcall(hplance_init_module);
-- 
2.6.0.rc3
