From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 5/7]: Fix ipip_fb_tunnel_dev leak in ipip_fini
Date: Sun, 03 Oct 2004 23:13:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B6F.5040204@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080504090100040504060908"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080504090100040504060908
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

ipip_fb_tunnel_dev doesn't have a destructor set
and is not freed manually. Set the destructor in
ipip_tunnel_setup to fix the leak.



--------------080504090100040504060908
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:42:17+02:00 kaber@coreworks.de 
#   [IPV4]: Fix ipip_fb_tunnel_dev leak in ipip_fini
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/ipip.c
#   2004/10/03 20:41:38+02:00 kaber@coreworks.de +1 -1
#   [IPV4]: Fix ipip_fb_tunnel_dev leak in ipip_fini
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/ipip.c b/net/ipv4/ipip.c
--- a/net/ipv4/ipip.c	2004-10-03 22:20:49 +02:00
+++ b/net/ipv4/ipip.c	2004-10-03 22:20:49 +02:00
@@ -246,7 +246,6 @@
 	nt = dev->priv;
 	SET_MODULE_OWNER(dev);
 	dev->init = ipip_tunnel_init;
-	dev->destructor = free_netdev;
 	nt->parms = *parms;
 
 	if (register_netdevice(dev) < 0) {
@@ -784,6 +783,7 @@
 	dev->get_stats		= ipip_tunnel_get_stats;
 	dev->do_ioctl		= ipip_tunnel_ioctl;
 	dev->change_mtu		= ipip_tunnel_change_mtu;
+	dev->destructor		= free_netdev;
 
 	dev->type		= ARPHRD_TUNNEL;
 	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);

--------------080504090100040504060908--
