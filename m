From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 08/10] switchdev: remove "ABORT" transaction phase
Date: Thu, 24 Sep 2015 10:02:47 +0200
Message-ID: <1443081769-11193-9-git-send-email-jiri@resnulli.us>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33287 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbIXIDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:03:02 -0400
Received: by wiclk2 with SMTP id lk2so16617832wic.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:03:01 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

No longer used by drivers, as transaction queue with item destructors
takes care of abort phase internally in switchdev code. So kill it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |  1 -
 net/switchdev/switchdev.c | 10 ++--------
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index f61ee38..9cf372f 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -19,7 +19,6 @@
 
 enum switchdev_trans_ph {
 	SWITCHDEV_TRANS_PREPARE,
-	SWITCHDEV_TRANS_ABORT,
 	SWITCHDEV_TRANS_COMMIT,
 };
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index d1c7d51..1adeeda 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -248,11 +248,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		 * released.
 		 */
 
-		if (err != -EOPNOTSUPP) {
-			trans.ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_attr_set(dev, attr, &trans);
+		if (err != -EOPNOTSUPP)
 			switchdev_trans_items_destroy(&trans);
-		}
 
 		return err;
 	}
@@ -334,11 +331,8 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 		 * released.
 		 */
 
-		if (err != -EOPNOTSUPP) {
-			trans.ph = SWITCHDEV_TRANS_ABORT;
-			__switchdev_port_obj_add(dev, obj, &trans);
+		if (err != -EOPNOTSUPP)
 			switchdev_trans_items_destroy(&trans);
-		}
 
 		return err;
 	}
-- 
1.9.3
