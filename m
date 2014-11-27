From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 11/21] bridge: move private brport flags to if_bridge.h so port drivers can use flags
Date: Thu, 27 Nov 2014 11:40:16 +0100
Message-ID: <1417084826-9875-12-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:54404 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430AbaK0Kkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:43 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so17751882wiv.4
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:42 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com
---
v3->v4:
-used BIT macro as suggested by Thomas
new in v3
---
 include/linux/if_bridge.h | 12 ++++++++++++
 net/bridge/br_private.h   | 10 ----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index fa2eca6..2c81a8e 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -15,6 +15,7 @@
 
 #include <linux/netdevice.h>
 #include <uapi/linux/if_bridge.h>
+#include <linux/bitops.h>
 
 struct br_ip {
 	union {
@@ -32,6 +33,17 @@ struct br_ip_list {
 	struct br_ip addr;
 };
 
+#define BR_HAIRPIN_MODE		BIT(0)
+#define BR_BPDU_GUARD		BIT(1)
+#define BR_ROOT_BLOCK		BIT(2)
+#define BR_MULTICAST_FAST_LEAVE	BIT(3)
+#define BR_ADMIN_COST		BIT(4)
+#define BR_LEARNING		BIT(5)
+#define BR_FLOOD		BIT(6)
+#define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING)
+#define BR_PROMISC		BIT(7)
+#define BR_PROXYARP		BIT(8)
+
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
 typedef int br_should_route_hook_t(struct sk_buff *skb);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index cc36fb3..aea3d13 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -164,16 +164,6 @@ struct net_bridge_port
 	struct rcu_head			rcu;
 
 	unsigned long 			flags;
-#define BR_HAIRPIN_MODE		0x00000001
-#define BR_BPDU_GUARD           0x00000002
-#define BR_ROOT_BLOCK		0x00000004
-#define BR_MULTICAST_FAST_LEAVE	0x00000008
-#define BR_ADMIN_COST		0x00000010
-#define BR_LEARNING		0x00000020
-#define BR_FLOOD		0x00000040
-#define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
-#define BR_PROMISC		0x00000080
-#define BR_PROXYARP		0x00000100
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_own_query	ip4_own_query;
-- 
1.9.3
