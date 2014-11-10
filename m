From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] cxgb4: Remove unnecessary struct in6_addr *
 casts
Date: Mon, 10 Nov 2014 11:23:39 -0800
Message-ID: <1415647419.8868.13.camel@perches.com>
References: <1415335574.23530.4.camel@perches.com>
	 <20141110.132837.1817456437352515704.davem@davemloft.net>
	 <1415645298.8868.10.camel@perches.com>
	 <20141110.140923.1795637220425531256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org, leedom@chelsio.com,
	anish@chelsio.com, praveenm@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	Junio C Hamano <gitster@pobox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0108.hostedemail.com ([216.40.44.108]:56997 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752127AbaKJTXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:23:44 -0500
In-Reply-To: <20141110.140923.1795637220425531256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-10 at 14:09 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 10 Nov 2014 10:48:18 -0800
> 
> > btw: using "git format-patch -M" makes reading and
> > verifying the patch a lot easier.
> > 
> > Unfortunately, there's no current way to make this
> > a global default for everyone, but I have this in
> > my ~/.gitconfig:

	[diff]
		renames = true

> None of those moves were pure moves, I adjusted the top-level
> cpp guard names in every file plus there were some path changes
> in net/bonding.h as well.

Hey again.

That doesn't really matter much as git's pretty smart about
renames with simultaneous changes.

The resultant emailed patch would have been 9k vs 86k.

fyi: Here's your patch with -M (or just using that .gitconfig entry)

(btw: thanks Junio)

---
>From 1ef8019be8799c39f316a772ffdd705c46029752 Mon Sep 17 00:00:00 2001
Message-Id: <1ef8019be8799c39f316a772ffdd705c46029752.1415646835.git.joe@perches.com>
From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 10 Nov 2014 13:27:49 -0500
Subject: [PATCH] net: Move bonding headers under include/net

This ways drivers like cxgb4 don't need to do ugly relative includes.

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_3ad.c                      |  4 ++--
 drivers/net/bonding/bond_alb.c                      |  4 ++--
 drivers/net/bonding/bond_debugfs.c                  |  4 ++--
 drivers/net/bonding/bond_main.c                     |  6 +++---
 drivers/net/bonding/bond_netlink.c                  |  2 +-
 drivers/net/bonding/bond_options.c                  |  2 +-
 drivers/net/bonding/bond_procfs.c                   |  2 +-
 drivers/net/bonding/bond_sysfs.c                    |  2 +-
 drivers/net/bonding/bond_sysfs_slave.c              |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  3 +--
 {drivers/net/bonding => include/net}/bond_3ad.h     |  6 +++---
 {drivers/net/bonding => include/net}/bond_alb.h     |  6 +++---
 {drivers/net/bonding => include/net}/bond_options.h |  6 +++---
 {drivers/net/bonding => include/net}/bonding.h      | 12 ++++++------
 14 files changed, 30 insertions(+), 31 deletions(-)
 rename {drivers/net/bonding => include/net}/bond_3ad.h (99%)
 rename {drivers/net/bonding => include/net}/bond_alb.h (98%)
 rename {drivers/net/bonding => include/net}/bond_options.h (97%)
 rename {drivers/net/bonding => include/net}/bonding.h (99%)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 2110215f..0a32143 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -29,8 +29,8 @@
 #include <linux/if_bonding.h>
 #include <linux/pkt_sched.h>
 #include <net/net_namespace.h>
-#include "bonding.h"
-#include "bond_3ad.h"
+#include <net/bonding.h>
+#include <net/bond_3ad.h>
 
 /* General definitions */
 #define AD_SHORT_TIMEOUT           1
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index baa58e7..e1f1a00 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -37,8 +37,8 @@
 #include <net/arp.h>
 #include <net/ipv6.h>
 #include <asm/byteorder.h>
-#include "bonding.h"
-#include "bond_alb.h"
+#include <net/bonding.h>
+#include <net/bond_alb.h>
 
 
 
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 8f99082..e52e25a 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -3,8 +3,8 @@
 #include <linux/device.h>
 #include <linux/netdevice.h>
 
-#include "bonding.h"
-#include "bond_alb.h"
+#include <net/bonding.h>
+#include <net/bond_alb.h>
 
 #if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_NET_NS)
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c752008..b9b3456 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -77,9 +77,9 @@
 #include <net/pkt_sched.h>
 #include <linux/rculist.h>
 #include <net/flow_keys.h>
-#include "bonding.h"
-#include "bond_3ad.h"
-#include "bond_alb.h"
+#include <net/bonding.h>
+#include <net/bond_3ad.h>
+#include <net/bond_alb.h>
 
 /*---------------------------- Module parameters ----------------------------*/
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index c13d83e..3e6eebd 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -17,7 +17,7 @@
 #include <linux/if_ether.h>
 #include <net/netlink.h>
 #include <net/rtnetlink.h>
-#include "bonding.h"
+#include <net/bonding.h>
 
 static size_t bond_get_slave_size(const struct net_device *bond_dev,
 				  const struct net_device *slave_dev)
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index b62697f..1a61cc9 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -16,7 +16,7 @@
 #include <linux/rcupdate.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
-#include "bonding.h"
+#include <net/bonding.h>
 
 static int bond_option_active_slave_set(struct bonding *bond,
 					const struct bond_opt_value *newval);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index a3948f8..976f5ad 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -2,7 +2,7 @@
 #include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
-#include "bonding.h"
+#include <net/bonding.h>
 
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8ffbafd..7e9e151 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -40,7 +40,7 @@
 #include <net/netns/generic.h>
 #include <linux/nsproxy.h>
 
-#include "bonding.h"
+#include <net/bonding.h>
 
 #define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index b01b0ce..23618a8 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -12,7 +12,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 
-#include "bonding.h"
+#include <net/bonding.h>
 
 struct slave_attribute {
 	struct attribute attr;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a9c117f..d13d36a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -61,6 +61,7 @@
 #include <net/neighbour.h>
 #include <net/netevent.h>
 #include <net/addrconf.h>
+#include <net/bonding.h>
 #include <asm/uaccess.h>
 
 #include "cxgb4.h"
@@ -71,8 +72,6 @@
 #include "cxgb4_debugfs.h"
 #include "l2t.h"
 
-#include <../drivers/net/bonding/bonding.h>
-
 #ifdef DRV_VERSION
 #undef DRV_VERSION
 #endif
diff --git a/drivers/net/bonding/bond_3ad.h b/include/net/bond_3ad.h
similarity index 99%
rename from drivers/net/bonding/bond_3ad.h
rename to include/net/bond_3ad.h
index c5f14ac..e01d903 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/include/net/bond_3ad.h
@@ -20,8 +20,8 @@
  *
  */
 
-#ifndef __BOND_3AD_H__
-#define __BOND_3AD_H__
+#ifndef _NET_BOND_3AD_H
+#define _NET_BOND_3AD_H
 
 #include <asm/byteorder.h>
 #include <linux/skbuff.h>
@@ -279,5 +279,5 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 void bond_3ad_update_lacp_rate(struct bonding *bond);
-#endif /* __BOND_3AD_H__ */
+#endif /* _NET_BOND_3AD_H */
 
diff --git a/drivers/net/bonding/bond_alb.h b/include/net/bond_alb.h
similarity index 98%
rename from drivers/net/bonding/bond_alb.h
rename to include/net/bond_alb.h
index 1ad473b..313a8d3 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/include/net/bond_alb.h
@@ -19,8 +19,8 @@
  *
  */
 
-#ifndef __BOND_ALB_H__
-#define __BOND_ALB_H__
+#ifndef _NET_BOND_ALB_H
+#define _NET_BOND_ALB_H
 
 #include <linux/if_ether.h>
 
@@ -177,5 +177,5 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
-#endif /* __BOND_ALB_H__ */
+#endif /* _NET_BOND_ALB_H */
 
diff --git a/drivers/net/bonding/bond_options.h b/include/net/bond_options.h
similarity index 97%
rename from drivers/net/bonding/bond_options.h
rename to include/net/bond_options.h
index 17ded5b..ea6546d 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/include/net/bond_options.h
@@ -8,8 +8,8 @@
  * (at your option) any later version.
  */
 
-#ifndef _BOND_OPTIONS_H
-#define _BOND_OPTIONS_H
+#ifndef _NET_BOND_OPTIONS_H
+#define _NET_BOND_OPTIONS_H
 
 #define BOND_OPT_MAX_NAMELEN 32
 #define BOND_OPT_VALID(opt) ((opt) < BOND_OPT_LAST)
@@ -127,4 +127,4 @@ static inline void __bond_opt_init(struct bond_opt_value *optval,
 
 void bond_option_arp_ip_targets_clear(struct bonding *bond);
 
-#endif /* _BOND_OPTIONS_H */
+#endif /* _NET_BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bonding.h b/include/net/bonding.h
similarity index 99%
rename from drivers/net/bonding/bonding.h
rename to include/net/bonding.h
index bfb0b51..983a94b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/include/net/bonding.h
@@ -12,8 +12,8 @@
  *
  */
 
-#ifndef _LINUX_BONDING_H
-#define _LINUX_BONDING_H
+#ifndef _NET_BONDING_H
+#define _NET_BONDING_H
 
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
@@ -26,9 +26,9 @@
 #include <linux/reciprocal_div.h>
 #include <linux/if_link.h>
 
-#include "bond_3ad.h"
-#include "bond_alb.h"
-#include "bond_options.h"
+#include <net/bond_3ad.h>
+#include <net/bond_alb.h>
+#include <net/bond_options.h>
 
 #define DRV_VERSION	"3.7.1"
 #define DRV_RELDATE	"April 27, 2011"
@@ -651,4 +651,4 @@ static inline void bond_tx_drop(struct net_device *dev, struct sk_buff *skb)
 	dev_kfree_skb_any(skb);
 }
 
-#endif /* _LINUX_BONDING_H */
+#endif /* _NET_BONDING_H */
-- 
2.1.2
