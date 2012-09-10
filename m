From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net v2] ixp4xx_hss: fix build failure due to missing linux/module.h inclusion
Date: Mon, 10 Sep 2012 14:06:58 +0200
Message-ID: <1347278818-6913-1-git-send-email-florian@openwrt.org>
Cc: khc@pm.waw.pl, joe@perches.com, David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>, stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:39204 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805Ab2IJMHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 08:07:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 36a1211970193ce215de50ed1e4e1272bc814df1 (netprio_cgroup.h:
dont include module.h from other includes) made the following build
error on ixp4xx_hss pop up:

  CC [M]  drivers/net/wan/ixp4xx_hss.o
 drivers/net/wan/ixp4xx_hss.c:1412:20: error: expected ';', ',' or ')'
 before string constant
 drivers/net/wan/ixp4xx_hss.c:1413:25: error: expected ';', ',' or ')'
 before string constant
 drivers/net/wan/ixp4xx_hss.c:1414:21: error: expected ';', ',' or ')'
 before string constant
 drivers/net/wan/ixp4xx_hss.c:1415:19: error: expected ';', ',' or ')'
 before string constant
 make[8]: *** [drivers/net/wan/ixp4xx_hss.o] Error 1

This was previously hidden because ixp4xx_hss includes linux/hdlc.h which
includes linux/netdevice.h which includes linux/netprio_cgroup.h which
used to include linux/module.h. The real issue was actually present since
the initial commit that added this driver since it uses macros from
linux/module.h without including this file.

CC: stable@vger.kernel.org
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
[stable: 3.3+]

Changes since v1:
- properly identify the bad commit

 drivers/net/wan/ixp4xx_hss.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index aaaca9a..3f575af 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -10,6 +10,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/module.h>
 #include <linux/bitops.h>
 #include <linux/cdev.h>
 #include <linux/dma-mapping.h>
-- 
1.7.9.5
