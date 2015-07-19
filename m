From: sfeldma@gmail.com
Subject: [PATCH net-next v3 2/5] net: add phys ID compare helper to test if two IDs are the same
Date: Sat, 18 Jul 2015 18:24:49 -0700
Message-ID: <1437269092-17669-3-git-send-email-sfeldma@gmail.com>
References: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com, nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36813 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbbGSBWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 21:22:38 -0400
Received: by pdjr16 with SMTP id r16so83495228pdj.3
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 18:22:37 -0700 (PDT)
In-Reply-To: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |    7 +++++++
 net/switchdev/switchdev.c |    8 ++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8364f29..607b5f4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -766,6 +766,13 @@ struct netdev_phys_item_id {
 	unsigned char id_len;
 };
 
+static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
+					    struct netdev_phys_item_id *b)
+{
+	return a->id_len == b->id_len &&
+	       memcmp(a->id, b->id, a->id_len) == 0;
+}
+
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 9f2add3..4e5bba5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -910,13 +910,9 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 		if (switchdev_port_attr_get(dev, &attr))
 			return NULL;
 
-		if (nhsel > 0) {
-			if (prev_attr.u.ppid.id_len != attr.u.ppid.id_len)
+		if (nhsel > 0 &&
+		    !netdev_phys_item_id_same(&prev_attr.u.ppid, &attr.u.ppid))
 				return NULL;
-			if (memcmp(prev_attr.u.ppid.id, attr.u.ppid.id,
-				   attr.u.ppid.id_len))
-				return NULL;
-		}
 
 		prev_attr = attr;
 	}
-- 
1.7.10.4
