From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 5/6] net/ethernet: make 8390/mac8390.c driver explicitly non-modular
Date: Mon, 28 Sep 2015 15:51:29 -0400
Message-ID: <1443469890-19485-6-git-send-email-paul.gortmaker@windriver.com>
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

The Kconfig for this option is currently:

config MAC8390
    bool "Macintosh NS 8390 based ethernet cards"

...meaning that it currently is not being built as a module by anyone.
Lets remove the modular code that is essentially orphaned -- it was never
even updated to use module_init/module_exit.  After this, when reading
the driver there should be no doubt it is builtin-only.

We don't swap module.h for init.h since this file has init.h already.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.

We move the information from MODULE_AUTHOR to the comments at the top
of the file for documentation purposes.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/8390/mac8390.c | 40 ++-----------------------------------
 1 file changed, 2 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index 65cf60f6718c..a971bf629715 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -4,6 +4,8 @@
    taken from or inspired by skeleton.c by Donald Becker, acenic.c by
    Jes Sorensen, and ne2k-pci.c by Donald Becker and Paul Gortmaker.
 
+   Author: David Huggins-Daines <dhd@debian.org> and others.
+
    This software may be used and distributed according to the terms of
    the GNU Public License, incorporated herein by reference.  */
 
@@ -19,7 +21,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
@@ -449,43 +450,6 @@ out:
 	return ERR_PTR(err);
 }
 
-#ifdef MODULE
-MODULE_AUTHOR("David Huggins-Daines <dhd@debian.org> and others");
-MODULE_DESCRIPTION("Macintosh NS8390-based Nubus Ethernet driver");
-MODULE_LICENSE("GPL");
-
-/* overkill, of course */
-static struct net_device *dev_mac8390[15];
-int init_module(void)
-{
-	int i;
-	for (i = 0; i < 15; i++) {
-		struct net_device *dev = mac8390_probe(-1);
-		if (IS_ERR(dev))
-			break;
-		dev_mac890[i] = dev;
-	}
-	if (!i) {
-		pr_notice("No useable cards found, driver NOT installed.\n");
-		return -ENODEV;
-	}
-	return 0;
-}
-
-void cleanup_module(void)
-{
-	int i;
-	for (i = 0; i < 15; i++) {
-		struct net_device *dev = dev_mac890[i];
-		if (dev) {
-			unregister_netdev(dev);
-			free_netdev(dev);
-		}
-	}
-}
-
-#endif /* MODULE */
-
 static const struct net_device_ops mac8390_netdev_ops = {
 	.ndo_open 		= mac8390_open,
 	.ndo_stop		= mac8390_close,
-- 
2.6.0.rc3
