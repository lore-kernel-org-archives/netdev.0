From: sfeldma@gmail.com
Subject: [PATCH net-next v3 3/7] bridge: define some min/max/default ageing time constants
Date: Wed, 23 Sep 2015 08:39:16 -0700
Message-ID: <1443022760-21301-4-git-send-email-sfeldma@gmail.com>
References: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34859 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbbIWPgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:36:12 -0400
Received: by pacfv12 with SMTP id fv12so44232742pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:36:11 -0700 (PDT)
In-Reply-To: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
v2: Per Jiri review comment: add BR_DEFAULT_AGEING_TIME to defines

 include/linux/if_bridge.h |    6 ++++++
 net/bridge/br_device.c    |    2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index dad8b00..a338a68 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -46,6 +46,12 @@ struct br_ip_list {
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
 
+/* values as per ieee8021QBridgeFdbAgingTime */
+#define BR_MIN_AGEING_TIME	(10 * HZ)
+#define BR_MAX_AGEING_TIME	(1000000 * HZ)
+
+#define BR_DEFAULT_AGEING_TIME	(300 * HZ)
+
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
 typedef int br_should_route_hook_t(struct sk_buff *skb);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 6ed2feb..2f81624 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -391,7 +391,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_max_age = br->max_age = 20 * HZ;
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
-	br->ageing_time = 300 * HZ;
+	br->ageing_time = BR_DEFAULT_AGEING_TIME;
 
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
-- 
1.7.10.4
