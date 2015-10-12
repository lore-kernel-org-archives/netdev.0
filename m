From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 1/7] switchdev: assert rtnl in switchdev_port_obj_del
Date: Mon, 12 Oct 2015 17:45:44 +0200
Message-ID: <1444664750-11260-2-git-send-email-jiri@resnulli.us>
References: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36810 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbJLPpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 11:45:54 -0400
Received: by wicgb1 with SMTP id gb1so154341776wic.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 08:45:53 -0700 (PDT)
In-Reply-To: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
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
index 7a9ab90..a79ee44 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -366,6 +366,8 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
  *	@dev: port device
  *	@id: object ID
  *	@obj: object to delete
+ *
+ *	rtnl_lock must be held.
  */
 int switchdev_port_obj_del(struct net_device *dev,
 			   const struct switchdev_obj *obj)
@@ -375,6 +377,8 @@ int switchdev_port_obj_del(struct net_device *dev,
 	struct list_head *iter;
 	int err = -EOPNOTSUPP;
 
+	ASSERT_RTNL();
+
 	if (ops && ops->switchdev_port_obj_del)
 		return ops->switchdev_port_obj_del(dev, obj);
 
-- 
1.9.3
