From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 7/7]: Missing rtnl_unlock in register_vlan_device error
 path
Date: Sun, 03 Oct 2004 23:13:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B88.1000003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070603080609060007050008"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070603080609060007050008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

rtnl_unlock is not called in the out_free_unregister error path.



--------------070603080609060007050008
Content-Type: text/x-patch;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="07.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:44:53+02:00 kaber@coreworks.de 
#   [VLAN]: Missing rtnl_unlock in register_vlan_device error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/8021q/vlan.c
#   2004/10/03 20:44:27+02:00 kaber@coreworks.de +1 -1
#   [VLAN]: Missing rtnl_unlock in register_vlan_device error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	2004-10-03 22:21:30 +02:00
+++ b/net/8021q/vlan.c	2004-10-03 22:21:30 +02:00
@@ -537,7 +537,7 @@
 
 out_free_unregister:
 	unregister_netdev(new_dev);
-	goto out_put_dev;
+	goto out_unlock;
 
 out_free_newdev:
 	free_netdev(new_dev);

--------------070603080609060007050008--
