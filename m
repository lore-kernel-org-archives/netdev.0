From: janitor@sternwelten.at
Subject: [patch 1/2]  linux-2.6.7/net/8021q/vlan.c: add error check
Date: Sat, 20 Nov 2004 03:42:57 +0100
Message-ID: <E1CVLDF-00026h-OK@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, WHarms@bfs.de, wharms@bfs.de
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Content-type: text/plain; charset=us-ascii

Hi list,
the patches are still for 2.6.7.
The remaining issues are solved (hopefully). i have added
spaces before and after "=".
in ipx i moved the __init strings back and added a comment
form acme to say why.

unfortunly my hopes of having a working smtp mail system didnt
come true. so i have still to use c&p what may result in 
<tab> -> <space> probelms.

---------------------------------------------------------

add error check for register_netdevice_notifier()

Signed-off-by: walter harms <wharms@bfs.de>

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
---

 linux-2.6.10-rc2-bk4-max/net/8021q/vlan.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff -puN net/8021q/vlan.c~check-register_netdevice_notifier-net_8021q_vlan net/8021q/vlan.c
--- linux-2.6.10-rc2-bk4/net/8021q/vlan.c~check-register_netdevice_notifier-net_8021q_vlan	2004-11-20 03:01:53.000000000 +0100
+++ linux-2.6.10-rc2-bk4-max/net/8021q/vlan.c	2004-11-20 03:01:53.000000000 +0100
@@ -102,7 +102,12 @@ static int __init vlan_proto_init(void)
 	dev_add_pack(&vlan_packet_type);
 
 	/* Register us to receive netdevice events */
-	register_netdevice_notifier(&vlan_notifier_block);
+	err = register_netdevice_notifier(&vlan_notifier_block);
+	if (err < 0) {
+		dev_remove_pack(&vlan_packet_type);
+		vlan_proc_cleanup();
+		return 1;
+	}
 
 	vlan_ioctl_set(vlan_ioctl_handler);
 
_
