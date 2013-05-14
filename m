From: Simon Horman <horms+renesas@verge.net.au>
Subject: [RFC PATCH net-next v2 1/3] sh_eth: add support for gpio reset
Date: Tue, 14 May 2013 11:37:51 +0900
Message-ID: <1368499073-21975-2-git-send-email-horms+renesas@verge.net.au>
References: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow reset using a GPIO. In order to use this set the following
in the device's platform data:

	needs_gpio_reset = 1
	reset_gpio = GPIO pin to use

This patch is motivated by the lager board which uses the r8a7790 SoC
which has a GPIO pin to reset its sh_eth device.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

--

v2
* First post
---
 drivers/net/ethernet/renesas/sh_eth.c | 4 ++++
 include/linux/sh_eth.h                | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33dc6f2..016cf80 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -21,6 +21,7 @@
  *  the file called "COPYING".
  */
 
+#include <linux/gpio.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -2759,6 +2760,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		ndev->features = NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
+	if (pd->needs_gpio_reset)
+		gpio_request_one(pd->reset_gpio, GPIOF_OUT_INIT_HIGH, NULL);
+
 	/* initialize first or needed device */
 	if (!devno || pd->needs_init) {
 		if (mdp->cd->chip_reset)
diff --git a/include/linux/sh_eth.h b/include/linux/sh_eth.h
index fc30571..b3f1550 100644
--- a/include/linux/sh_eth.h
+++ b/include/linux/sh_eth.h
@@ -22,6 +22,9 @@ struct sh_eth_plat_data {
 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
 	unsigned needs_init:1;
+	unsigned needs_gpio_reset:1;
+
+	unsigned reset_gpio;	/* Used if needs_gpio_reset is true */
 };
 
 #endif
-- 
1.8.2.1

