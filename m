From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 04/13] net: dsa: provide a switch device device tree node pointer
Date: Wed, 27 Aug 2014 17:04:49 -0700
Message-ID: <1409184298-1793-5-git-send-email-f.fainelli@gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:58333 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964973AbaH1AGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 20:06:07 -0400
Received: by mail-pa0-f47.google.com with SMTP id hz1so116956pad.6
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 17:06:06 -0700 (PDT)
In-Reply-To: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We might need to fetch additional resources from the device tree node
pointer, such as register ranges or other properties. Keep a device_node
pointer around for this.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 7 +++++++
 net/dsa/dsa.c     | 1 +
 2 files changed, 8 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6e26f1e4d8ce..decc62709acd 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -15,6 +15,7 @@
 #include <linux/list.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
+#include <linux/of.h>
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -26,6 +27,12 @@ struct dsa_chip_data {
 	struct device	*mii_bus;
 	int		sw_addr;
 
+	/* Device tree node pointer for this specific switch chip
+	 * used during switch setup in case additional properties
+	 * and resources needs to be used
+	 */
+	struct device_node *of_node;
+
 	/*
 	 * The names of the switch's ports.  Use "cpu" to
 	 * designate the switch port that the cpu is connected to,
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 92e71d2a2ccd..a28ef432d016 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -410,6 +410,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 		chip_index++;
 		cd = &pd->chip[chip_index];
 
+		cd->of_node = child;
 		cd->mii_bus = &mdio_bus->dev;
 
 		sw_addr = of_get_property(child, "reg", NULL);
-- 
1.9.1
