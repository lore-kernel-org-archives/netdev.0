From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 03/11] net: dsa: provide a switch device device tree node pointer
Date: Tue, 13 May 2014 22:00:29 -0700
Message-ID: <1400043637-9799-4-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:38669 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbaENFBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:18 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so1187633pad.2
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:17 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
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
index 0ada9c814ff9..9a16c5290738 100644
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
index 0eb5d5e76dfb..7808dbceff96 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -410,6 +410,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 	for_each_available_child_of_node(np, child) {
 		cd = &pd->chip[chip_index];
 
+		cd->of_node = child;
 		cd->mii_bus = &mdio_bus->dev;
 
 		sw_addr = of_get_property(child, "reg", NULL);
-- 
1.9.1
