From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] net-sysfs parent ref count
Date: Tue, 10 Jun 2003 13:35:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610133508.3d0bfffc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When creating network sysfs entries, we grab an extra reference to the parent.
Not a big deal now, since it just gets blown away on unregister anyway, but when
kobject reference counts are used for release, things break.

diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Tue Jun 10 11:11:42 2003
+++ b/net/core/net-sysfs.c	Tue Jun 10 11:11:42 2003
@@ -299,17 +299,11 @@
 		    goto out_unreg;
 	}
 
-	
 	net->stats_kobj.parent = NULL;
 	if (net->get_stats) {
 		struct kobject *k = &net->stats_kobj;
 
-		k->parent = kobject_get(&class_dev->kobj);
-		if (!k->parent) {
-			ret = -EBUSY;
-			goto out_unreg;
-		}
-
+		k->parent = &class_dev->kobj;
 		strlcpy(k->name, "statistics", KOBJ_NAME_LEN);
 		k->ktype = &netstat_ktype;
 
