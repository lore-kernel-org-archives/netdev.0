From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v2 net-next 1/1] net: fec: fix build error at m68k platform
Date: Fri, 3 Oct 2014 14:29:14 -0700
Message-ID: <1412371754-60384-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <davem@davemloft.net>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0116.outbound.protection.outlook.com ([157.56.111.116]:44981
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750832AbaJCV31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 17:29:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reproduce:
  wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
  chmod +x ~/bin/make.cross
  git checkout 1b7bde6d659d30f171259cc2dfba8e5dab34e735

  make.cross ARCH=m68k m5275evb_defconfig
  make.cross ARCH=m68k

All error/warnings:

   drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_rx_queue':
>> drivers/net/ethernet/freescale/fec_main.c:1470:3: error: implicit declaration of function 'prefetch' [-Werror=implicit-function-declaration]
      prefetch(skb->data - NET_IP_ALIGN);
      ^
   cc1: some warnings being treated as errors

missed included prefetch.h

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
Change from v1 to V2
 - add reported by
 - add make config

 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1f07db8..e190eb0 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -57,6 +57,7 @@
 #include <linux/regulator/consumer.h>
 #include <linux/if_vlan.h>
 #include <linux/pinctrl/consumer.h>
+#include <linux/prefetch.h>
 
 #include <asm/cacheflush.h>
 
-- 
1.9.1
