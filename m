From: sfeldma@gmail.com
Subject: [RFC PATCH net-next v2 2/5] net: add phys ID compare helper to test if two IDs are the same
Date: Wed, 17 Jun 2015 14:53:11 -0700
Message-ID: <1434577994-22409-3-git-send-email-sfeldma@gmail.com>
References: <1434577994-22409-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34904 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbbFQVvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 17:51:20 -0400
Received: by pacyx8 with SMTP id yx8so45481179pac.2
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 14:51:19 -0700 (PDT)
In-Reply-To: <1434577994-22409-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/netdevice.h |    7 +++++++
 net/switchdev/switchdev.c |    8 ++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7be616e1..63090ce 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -766,6 +766,13 @@ struct netdev_phys_item_id {
 	unsigned char id_len;
 };
 
+static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
+					    struct netdev_phys_item_id *b)
+{
+	return ((a->id_len == b->id_len) &&
+		(memcmp(a->id, b->id, a->id_len) == 0));
+}
+
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a5d0f8e..00c67a5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -791,13 +791,9 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
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
