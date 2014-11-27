From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 12/21] bridge: add new brport flag LEARNING_SYNC
Date: Thu, 27 Nov 2014 11:40:17 +0100
Message-ID: <1417084826-9875-13-git-send-email-jiri@resnulli.us>
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
Received: from mail-wg0-f52.google.com ([74.125.82.52]:54955 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbaK0Kko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:44 -0500
Received: by mail-wg0-f52.google.com with SMTP id a1so6089058wgh.11
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:43 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This policy flag controls syncing of learned FDB entries to bridge's FDB.  If
on, FDB entries learned on bridge port device will be synced.  If off, device
may still learn new FDB entries but they will not be synced with bridge's FDB.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
v3->v4:
-just resolved conflict caused by BIT change of previous patch
new in v3
---
 include/linux/if_bridge.h    | 1 +
 include/uapi/linux/if_link.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 2c81a8e..0a8ce76 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -43,6 +43,7 @@ struct br_ip_list {
 #define BR_AUTO_MASK		(BR_FLOOD | BR_LEARNING)
 #define BR_PROMISC		BIT(7)
 #define BR_PROXYARP		BIT(8)
+#define BR_LEARNING_SYNC	BIT(9)
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 623f1a7..f7d0d2d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -245,6 +245,7 @@ enum {
 	IFLA_BRPORT_LEARNING,	/* mac learning */
 	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
 	IFLA_BRPORT_PROXYARP,	/* proxy ARP */
+	IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
-- 
1.9.3
