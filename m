From: sfeldma@gmail.com
Subject: [PATCH net-next v2 2/5] net: add phys ID compare helper to test if two IDs are the same
Date: Thu, 16 Jul 2015 01:04:54 -0700
Message-ID: <1437033897-8050-3-git-send-email-sfeldma@gmail.com>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32858 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbbGPICp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:02:45 -0400
Received: by padck2 with SMTP id ck2so38614111pad.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:02:45 -0700 (PDT)
In-Reply-To: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
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
