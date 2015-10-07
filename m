From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/3] switchdev: assert rtnl in switchdev_port_obj_del
Date: Wed,  7 Oct 2015 20:30:50 +0200
Message-ID: <1444242652-17260-2-git-send-email-jiri@resnulli.us>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37642 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbbJGSa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:30:57 -0400
Received: by wicfx3 with SMTP id fx3so41062405wic.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 11:30:55 -0700 (PDT)
In-Reply-To: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

RTNL mutex needs to be held for this function.
Safe usage of netdev_for_each_lower_dev requires that.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/switchdev/switchdev.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 6e4a4f9..3fb05d5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -359,6 +359,8 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
  *	@dev: port device
  *	@id: object ID
  *	@obj: object to delete
+ *
+ *	rtnl_lock must be held.
  */
 int switchdev_port_obj_del(struct net_device *dev,
 			   const struct switchdev_obj *obj)
@@ -368,6 +370,8 @@ int switchdev_port_obj_del(struct net_device *dev,
 	struct list_head *iter;
 	int err = -EOPNOTSUPP;
 
+	ASSERT_RTNL();
+
 	if (ops && ops->switchdev_port_obj_del)
 		return ops->switchdev_port_obj_del(dev, obj);
 
-- 
1.9.3
