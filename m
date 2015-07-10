From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: switchdev: don't abort unsupported operations
Date: Fri, 10 Jul 2015 19:48:58 -0400
Message-ID: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to abort attribute setting or object addition, if the
prepare phase returned operation not supported.

Thus, abort these two transactions only if the error is not -EOPNOTSUPP.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/switchdev/switchdev.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 84f77a0..9f2add3 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -171,8 +171,10 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 		 * released.
 		 */
 
-		attr->trans = SWITCHDEV_TRANS_ABORT;
-		__switchdev_port_attr_set(dev, attr);
+		if (err != -EOPNOTSUPP) {
+			attr->trans = SWITCHDEV_TRANS_ABORT;
+			__switchdev_port_attr_set(dev, attr);
+		}
 
 		return err;
 	}
@@ -249,8 +251,10 @@ int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
 		 * released.
 		 */
 
-		obj->trans = SWITCHDEV_TRANS_ABORT;
-		__switchdev_port_obj_add(dev, obj);
+		if (err != -EOPNOTSUPP) {
+			obj->trans = SWITCHDEV_TRANS_ABORT;
+			__switchdev_port_obj_add(dev, obj);
+		}
 
 		return err;
 	}
-- 
2.4.5
