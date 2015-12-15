From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH bluetooth-next] 6lowpan: fix debugfs interface entry name
Date: Tue, 15 Dec 2015 12:25:35 +0100
Message-ID: <1450178735-1572-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patches moves the debugfs interface related register after
netdevice register. The function lowpan_dev_debugfs_init will use
"dev->name" which can be before register_netdevice a format string.
The function register_netdevice will evaluate the format string if
necessary and replace "dev->name" to the real interface name.

Reported-by: Lukasz Duda <lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org>
Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/6lowpan/core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index c7f06f5..faf65ba 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -29,13 +29,13 @@ int lowpan_register_netdevice(struct net_device *dev,
 
 	lowpan_priv(dev)->lltype = lltype;
 
-	ret = lowpan_dev_debugfs_init(dev);
+	ret = register_netdevice(dev);
 	if (ret < 0)
 		return ret;
 
-	ret = register_netdevice(dev);
+	ret = lowpan_dev_debugfs_init(dev);
 	if (ret < 0)
-		lowpan_dev_debugfs_exit(dev);
+		unregister_netdevice(dev);
 
 	return ret;
 }
-- 
2.6.1
