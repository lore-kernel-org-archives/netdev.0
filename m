From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: [PATCH] bridge:Fix incorrect variable assignment on error path in br_sysfs_addbr
Date: Sun,  3 Apr 2016 19:04:26 -0400
Message-ID: <1459724666-3666-1-git-send-email-bastienphilbert@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the incorrect variable assignment on error path in
br_sysfs_addbr for when the call to kobject_create_and_add
fails to assign the value of -EINVAL to the returned variable of
err rather then incorrectly return zero making callers think this
function has succeededed due to the previous assignment being
assigned zero when assigning it the successful return value of
the call to sysfs_create_group which is zero.

Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
---
 net/bridge/br_sysfs_br.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 6b80914..f4d40ed 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -870,6 +870,7 @@ int br_sysfs_addbr(struct net_device *dev)
 
 	br->ifobj = kobject_create_and_add(SYSFS_BRIDGE_PORT_SUBDIR, brobj);
 	if (!br->ifobj) {
+		err = -EINVAL;
 		pr_info("%s: can't add kobject (directory) %s/%s\n",
 			__func__, dev->name, SYSFS_BRIDGE_PORT_SUBDIR);
 		goto out3;
-- 
2.5.0
