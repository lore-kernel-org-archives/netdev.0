From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] net: cpts: fix for build break after ARM SoC integration
Date: Tue, 27 Nov 2012 15:57:14 +0530
Message-ID: <1354012034-31686-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	<richardcochran@gmail.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  CC      drivers/net/ethernet/ti/cpts.o
drivers/net/ethernet/ti/cpts.c:30:24: fatal error: plat/clock.h: No such file or directory
compilation terminated.
make[4]: *** [drivers/net/ethernet/ti/cpts.o] Error 1
make[3]: *** [drivers/net/ethernet/ti] Error 2
make[2]: *** [drivers/net/ethernet] Error 2
make[1]: *** [drivers/net] Error 2

fix for build break as the header file is removed from plat-omap as part of
the below patch

commit a135eaae524acba1509a3b19c97fae556e4da7cd
Author: Paul Walmsley <paul@pwsan.com>
Date:   Thu Sep 27 10:33:34 2012 -0600

    ARM: OMAP: remove plat/clock.h

    Remove arch/arm/plat-omap/include/plat/clock.h by merging it into
    arch/arm/mach-omap1/clock.h and arch/arm/mach-omap2/clock.h.
    The goal here is to facilitate ARM single image kernels by removing
    includes via the "plat/" symlink.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpts.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 3377667..5e62c1a 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -27,8 +27,6 @@
 #include <linux/uaccess.h>
 #include <linux/workqueue.h>
 
-#include <plat/clock.h>
-
 #include "cpts.h"
 
 #ifdef CONFIG_TI_CPTS
-- 
1.7.0.4

