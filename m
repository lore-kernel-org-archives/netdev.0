From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 09/14 v2] ieee802154: remove ieee802154
	policy from globals
Date: Mon, 26 Dec 2011 20:10:13 +0300
Message-ID: <1324919413-15146-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This item is used inside ieee802154 layer only and it shouldn't be
defined in headers, common for multiple layers. But at the same time it
can't be marked as static because it's used in several files inside
ieee802154 layer. So just move ieee802154 netlink policy array
definition to more appropriate place.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/nl802154.h    |    2 --
 net/ieee802154/ieee802154.h |    2 ++
 net/ieee802154/wpan-class.c |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 33d9f51..d2b5ae2 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -74,8 +74,6 @@ enum {
 
 #define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
 
-extern const struct nla_policy ieee802154_policy[];
-
 /* commands */
 /* REQ should be responded with CONF
  * and INDIC with RESP
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index aadec42..e9799af 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -21,6 +21,8 @@
 int __init ieee802154_nl_init(void);
 void __exit ieee802154_nl_exit(void);
 
+extern const struct nla_policy ieee802154_policy[];
+
 #define IEEE802154_OP(_cmd, _func)			\
 	{						\
 		.cmd	= _cmd,				\
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 1627ef2..36d32e2 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/device.h>
 
+#include <net/netlink.h>
 #include <net/wpan-phy.h>
 
 #include "ieee802154.h"
-- 
1.7.2.3


------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
