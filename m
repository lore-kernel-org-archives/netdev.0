From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] ieee802154: move headers out of
	extra directory
Date: Mon, 27 Jul 2009 18:08:14 +0400
Message-ID: <1248703695-7043-3-git-send-email-dbaryshkov@gmail.com>
References: <1248703695-7043-1-git-send-email-dbaryshkov@gmail.com>
	<1248703695-7043-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1248703695-7043-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

include/net/ieee802154/af_ieee802154.h (and others) naming seems to be too long
and redundant. Drop one level of subdirectories.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/ieee802154/fakehard.c                      |    8 ++++----
 include/net/{ieee802154 => }/af_ieee802154.h       |    0
 include/net/{ieee802154/mac_def.h => ieee802154.h} |    4 ++--
 .../netdevice.h => ieee802154_netdev.h}            |    0
 include/net/{ieee802154 => }/nl802154.h            |    0
 net/ieee802154/af_ieee802154.c                     |    4 ++--
 net/ieee802154/dgram.c                             |    6 +++---
 net/ieee802154/netlink.c                           |    6 +++---
 net/ieee802154/raw.c                               |    2 +-
 9 files changed, 15 insertions(+), 15 deletions(-)
 rename include/net/{ieee802154 => }/af_ieee802154.h (100%)
 rename include/net/{ieee802154/mac_def.h => ieee802154.h} (98%)
 rename include/net/{ieee802154/netdevice.h => ieee802154_netdev.h} (100%)
 rename include/net/{ieee802154 => }/nl802154.h (100%)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 9ec07e8..8a52e6e 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -26,10 +26,10 @@
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 
-#include <net/ieee802154/af_ieee802154.h>
-#include <net/ieee802154/netdevice.h>
-#include <net/ieee802154/mac_def.h>
-#include <net/ieee802154/nl802154.h>
+#include <net/af_ieee802154.h>
+#include <net/ieee802154_netdev.h>
+#include <net/ieee802154.h>
+#include <net/nl802154.h>
 
 /**
  * fake_get_pan_id - Retrieve the PAN ID of the device.
diff --git a/include/net/ieee802154/af_ieee802154.h b/include/net/af_ieee802154.h
similarity index 100%
rename from include/net/ieee802154/af_ieee802154.h
rename to include/net/af_ieee802154.h
diff --git a/include/net/ieee802154/mac_def.h b/include/net/ieee802154.h
similarity index 98%
rename from include/net/ieee802154/mac_def.h
rename to include/net/ieee802154.h
index 8cb6846..d52685d 100644
--- a/include/net/ieee802154/mac_def.h
+++ b/include/net/ieee802154.h
@@ -23,8 +23,8 @@
  * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
  */
 
-#ifndef IEEE802154_MAC_DEF_H
-#define IEEE802154_MAC_DEF_H
+#ifndef NET_IEEE802154_H
+#define NET_IEEE802154_H
 
 #define IEEE802154_FC_TYPE_BEACON	0x0	/* Frame is beacon */
 #define	IEEE802154_FC_TYPE_DATA		0x1	/* Frame is data */
diff --git a/include/net/ieee802154/netdevice.h b/include/net/ieee802154_netdev.h
similarity index 100%
rename from include/net/ieee802154/netdevice.h
rename to include/net/ieee802154_netdev.h
diff --git a/include/net/ieee802154/nl802154.h b/include/net/nl802154.h
similarity index 100%
rename from include/net/ieee802154/nl802154.h
rename to include/net/nl802154.h
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 3bb6bdb..69c8d92 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -34,8 +34,8 @@
 #include <net/tcp_states.h>
 #include <net/route.h>
 
-#include <net/ieee802154/af_ieee802154.h>
-#include <net/ieee802154/netdevice.h>
+#include <net/af_ieee802154.h>
+#include <net/ieee802154_netdev.h>
 
 #include "af802154.h"
 
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 14d3984..53dd912 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -26,9 +26,9 @@
 #include <linux/if_arp.h>
 #include <linux/list.h>
 #include <net/sock.h>
-#include <net/ieee802154/af_ieee802154.h>
-#include <net/ieee802154/mac_def.h>
-#include <net/ieee802154/netdevice.h>
+#include <net/af_ieee802154.h>
+#include <net/ieee802154.h>
+#include <net/ieee802154_netdev.h>
 
 #include <asm/ioctls.h>
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 27eda9f..a615b9d 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -27,9 +27,9 @@
 #include <net/netlink.h>
 #include <net/genetlink.h>
 #include <linux/nl802154.h>
-#include <net/ieee802154/af_ieee802154.h>
-#include <net/ieee802154/nl802154.h>
-#include <net/ieee802154/netdevice.h>
+#include <net/af_ieee802154.h>
+#include <net/nl802154.h>
+#include <net/ieee802154_netdev.h>
 
 static unsigned int ieee802154_seq_num;
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index fca44d5..ea8d1f1 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -26,7 +26,7 @@
 #include <linux/if_arp.h>
 #include <linux/list.h>
 #include <net/sock.h>
-#include <net/ieee802154/af_ieee802154.h>
+#include <net/af_ieee802154.h>
 
 #include "af802154.h"
 
-- 
1.6.3.3


------------------------------------------------------------------------------
