From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] export correct symbols when INET not enabled
Date: Wed, 30 Jul 2003 12:51:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730125135.6b5d1945.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several symbols relating to multicast and netlink were hidden incorrectly under CONFIG_INET
when in fact they are needed now by drivers and available even without TCP/IP.

Patch against 2.6.0-test2 

diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Wed Jul 30 12:47:00 2003
+++ b/net/netsyms.c	Wed Jul 30 12:47:00 2003
@@ -513,20 +513,11 @@
 #endif
 
 EXPORT_SYMBOL(rtattr_parse);
-EXPORT_SYMBOL(rtnetlink_links);
 EXPORT_SYMBOL(__rta_fill);
-EXPORT_SYMBOL(rtnetlink_dump_ifinfo);
-EXPORT_SYMBOL(rtnetlink_put_metrics);
-EXPORT_SYMBOL(rtnl);
 EXPORT_SYMBOL(neigh_delete);
 EXPORT_SYMBOL(neigh_add);
 EXPORT_SYMBOL(neigh_dump_info);
 
-EXPORT_SYMBOL(dev_set_allmulti);
-EXPORT_SYMBOL(dev_set_promiscuity);
-EXPORT_SYMBOL(rtnl_sem);
-EXPORT_SYMBOL(rtnl_lock);
-EXPORT_SYMBOL(rtnl_unlock);
 
 /* ABI emulation layers need this */
 EXPORT_SYMBOL(move_addr_to_kernel);
@@ -534,7 +525,6 @@
                   
 /* Used by at least ipip.c.  */
 EXPORT_SYMBOL(ipv4_config);
-EXPORT_SYMBOL(dev_open);
 
 /* Used by other modules */
 EXPORT_SYMBOL(xrlim_allow);
@@ -610,11 +600,22 @@
 #endif
 EXPORT_SYMBOL(dev_base);
 EXPORT_SYMBOL(dev_base_lock);
+EXPORT_SYMBOL(dev_open);
 EXPORT_SYMBOL(dev_close);
 EXPORT_SYMBOL(dev_mc_add);
 EXPORT_SYMBOL(dev_mc_delete);
 EXPORT_SYMBOL(dev_mc_upload);
+EXPORT_SYMBOL(dev_set_allmulti);
+EXPORT_SYMBOL(dev_set_promiscuity);
 EXPORT_SYMBOL(__kill_fasync);
+
+EXPORT_SYMBOL(rtnl);
+EXPORT_SYMBOL(rtnetlink_links);
+EXPORT_SYMBOL(rtnetlink_dump_ifinfo);
+EXPORT_SYMBOL(rtnetlink_put_metrics);
+EXPORT_SYMBOL(rtnl_sem);
+EXPORT_SYMBOL(rtnl_lock);
+EXPORT_SYMBOL(rtnl_unlock);
 
 #ifdef CONFIG_HIPPI
 EXPORT_SYMBOL(hippi_type_trans);
