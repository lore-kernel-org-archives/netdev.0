From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 03/12] net: dsa: provide a switch device device tree node pointer
Date: Sun, 24 Aug 2014 11:44:20 -0700
Message-ID: <1408905869-10471-4-git-send-email-f.fainelli@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:47657 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbaHXSpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 14:45:07 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so19304505pab.0
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 11:45:06 -0700 (PDT)
In-Reply-To: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
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
index 36a397bfbd2e..91d5ba435ab6 100644
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
index 0a49632fac47..069586547cf5 100644
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
