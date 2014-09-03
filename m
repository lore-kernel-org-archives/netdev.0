From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/13] net: introduce netdev_phys_item_ids_match helper
Date: Wed,  3 Sep 2014 11:24:55 +0200
Message-ID: <1409736300-12303-9-git-send-email-jiri@resnulli.us>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:47580 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882AbaICJZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 05:25:27 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so492350wib.15
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 02:25:23 -0700 (PDT)
In-Reply-To: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 include/linux/netdevice.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7ee070f..b2c3ff0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -750,6 +750,13 @@ struct netdev_phys_item_id {
 	unsigned char id_len;
 };
 
+static inline bool netdev_phys_item_ids_match(struct netdev_phys_item_id *id1,
+					      struct netdev_phys_item_id *id2)
+{
+	return id1->id_len == id2->id_len &&
+	       !memcmp(id1->id, id2->id, id1->id_len);
+}
+
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
-- 
1.9.3
