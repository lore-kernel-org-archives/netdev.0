From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] vlan - device refcount bug.
Date: Tue, 3 Aug 2004 13:14:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803131425.503f8f45@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If you rmmod a network device that is in a vlan, the system hangs waiting
for the refcount to go to zero, because it is -1.  The problem is that the
vlan notifier does an extra dev_put in NETDEV_UNREGISTER case of notifier.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	2004-08-03 13:13:33 -07:00
+++ b/net/8021q/vlan.c	2004-08-03 13:13:33 -07:00
@@ -645,7 +645,6 @@
 			ret = unregister_vlan_dev(dev,
 						  VLAN_DEV_INFO(vlandev)->vlan_id);
 
-			dev_put(vlandev);
 			unregister_netdevice(vlandev);
 
 			/* Group was destroyed? */
