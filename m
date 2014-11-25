From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 14/17] bridge: add new brport flag LEARNING_SYNC
Date: Tue, 25 Nov 2014 11:28:45 +0100
Message-ID: <1416911328-10979-15-git-send-email-jiri@resnulli.us>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:40544 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188AbaKYK3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 05:29:09 -0500
Received: by mail-wg0-f41.google.com with SMTP id y19so419128wgg.28
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 02:29:08 -0800 (PST)
In-Reply-To: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This policy flag controls syncing of learned FDB entries to bridge's FDB.  If
on, FDB entries learned on bridge port device will be synced.  If off, device
may still learn new FDB entries but they will not be synced with bridge's FDB.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
new in v3
---
 include/linux/if_bridge.h    | 1 +
 include/uapi/linux/if_link.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index b4bb104..67b7a8e 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -42,6 +42,7 @@ struct br_ip_list {
 #define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
 #define BR_PROMISC		0x00000080
 #define BR_PROXYARP		0x00000100
+#define BR_LEARNING_SYNC	0x00000200
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 4163753..d8e6a31 100644
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
