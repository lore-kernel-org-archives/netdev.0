From: sfeldma@gmail.com
Subject: [PATCH net-next] switchdev: change BUG_ON to WARN for attr set failure case
Date: Thu, 11 Jun 2015 11:20:42 -0700
Message-ID: <1434046842-24601-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, dsahern@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34169 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930AbbFKSSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 14:18:44 -0400
Received: by pdbki1 with SMTP id ki1so8341767pdb.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 11:18:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This particular BUG_ON condition was checking for attr set err in the
COMMIT phase, which isn't expected (it's a driver bug if PREPARE phase is
OK but COMMIT fails).  But BUG_ON() is too strong for this case, so change
to WARN().  BUG_ON() would be warranted if the system was corrupted beyond
repair, but this is not the case here.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 658bc3a..a5d0f8e 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -184,7 +184,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 
 	attr->trans = SWITCHDEV_TRANS_COMMIT;
 	err = __switchdev_port_attr_set(dev, attr);
-	BUG_ON(err);
+	WARN(err, "%s: Commit of attribute (id=%d) failed.\n",
+	     dev->name, attr->id);
 
 	return err;
 }
-- 
1.7.10.4
