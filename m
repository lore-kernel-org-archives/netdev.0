From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] fec: Include pinctrl header file
Date: Mon, 2 Jun 2014 15:44:30 -0300
Message-ID: <1401734670-30141-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <B38611@freescale.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0183.outbound.protection.outlook.com ([207.46.163.183]:38492
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752543AbaFBSor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 14:44:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5bbde4d2ec ("net: fec: use pinctrl PM helpers") caused the following
build error on m68k:

drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_open':
drivers/net/ethernet/freescale/fec_main.c:1819:2: error: implicit declaration of function 'pinctrl_pm_select_default_state' [-Werror=implicit-function-declaration]
drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_close':
drivers/net/ethernet/freescale/fec_main.c:1863:2: error: implicit declaration of function 'pinctrl_pm_select_sleep_state' [-Werror=implicit-function-declaration]

In order to fix the build error, include the linux/pinctrl/consumer.h header
file.

Reported-by: kbuild test robot <fengguang.wu@intel.com> 
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4d989b2..802be17 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -54,6 +54,7 @@
 #include <linux/of_net.h>
 #include <linux/regulator/consumer.h>
 #include <linux/if_vlan.h>
+#include <linux/pinctrl/consumer.h>
 
 #include <asm/cacheflush.h>
 
-- 
1.8.3.2
