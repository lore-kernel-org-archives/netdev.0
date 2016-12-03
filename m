From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] net: bridge: set error code on failure
Date: Sat,  3 Dec 2016 19:33:23 +0800
Message-ID: <1480764803-5577-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function br_sysfs_addbr() does not set error code when the call
kobject_create_and_add() returns a NULL pointer. It may be better to
return "-ENOMEM" when kobject_create_and_add() fails.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188781

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/bridge/br_sysfs_br.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index e120307..f88c4df 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -898,6 +898,7 @@ int br_sysfs_addbr(struct net_device *dev)
 	if (!br->ifobj) {
 		pr_info("%s: can't add kobject (directory) %s/%s\n",
 			__func__, dev->name, SYSFS_BRIDGE_PORT_SUBDIR);
+		err = -ENOMEM;
 		goto out3;
 	}
 	return 0;
-- 
1.9.1
