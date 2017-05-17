From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: include dsa.h only once
Date: Wed, 17 May 2017 15:46:03 -0400
Message-ID: <20170517194605.31639-2-vivien.didelot@savoirfairelinux.com>
References: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The public include/net/dsa.h file is meant for DSA drivers, while all
DSA core files share a common private header net/dsa/dsa_priv.h file.

Ensure that dsa_priv.h is the only DSA core file to include net/dsa.h,
and add a new line to separate absolute and relative headers at the same
time.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c         | 2 +-
 net/dsa/dsa2.c        | 2 +-
 net/dsa/dsa_priv.h    | 1 +
 net/dsa/legacy.c      | 2 +-
 net/dsa/slave.c       | 2 +-
 net/dsa/switch.c      | 3 ++-
 net/dsa/tag_brcm.c    | 2 +-
 net/dsa/tag_dsa.c     | 2 +-
 net/dsa/tag_edsa.c    | 2 +-
 net/dsa/tag_lan9303.c | 2 +-
 net/dsa/tag_mtk.c     | 2 +-
 net/dsa/tag_qca.c     | 2 +-
 net/dsa/tag_trailer.c | 2 +-
 13 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 26130ae438da..54a52f4661b1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -24,7 +24,7 @@
 #include <linux/phy_fixed.h>
 #include <linux/gpio/consumer.h>
 #include <linux/etherdevice.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 2ac62349ba12..4301f52e4f5a 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -18,7 +18,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 static LIST_HEAD(dsa_switch_trees);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index f4a88e485213..904d5476c6e0 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -14,6 +14,7 @@
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <linux/netpoll.h>
+#include <net/dsa.h>
 
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index bb28b011ba5a..ac4379b8d7ac 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -22,7 +22,7 @@
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
 #include <linux/etherdevice.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 /* switch driver registration ***********************************************/
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 77324c483d14..fb13c5d7d587 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -17,13 +17,13 @@
 #include <linux/of_mdio.h>
 #include <linux/mdio.h>
 #include <linux/list.h>
-#include <net/dsa.h>
 #include <net/rtnetlink.h>
 #include <net/switchdev.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
 #include <linux/if_bridge.h>
 #include <linux/netpoll.h>
+
 #include "dsa_priv.h"
 
 static bool dsa_slave_dev_check(struct net_device *dev);
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index ca6e26e514f0..f477053308d2 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -12,7 +12,8 @@
 
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
-#include <net/dsa.h>
+
+#include "dsa_priv.h"
 
 static int dsa_switch_bridge_join(struct dsa_switch *ds,
 				  struct dsa_notifier_bridge_info *info)
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 658ddee63dc9..9f204f18ada3 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -12,7 +12,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 /* This tag length is 4 bytes, older ones were 6 bytes, we do not
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 1c6633f0de01..3b62a57956a3 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -11,7 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 #define DSA_HLEN	4
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index d9c668aa5e54..f95cafd05702 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -11,7 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 #define DSA_HLEN	4
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 70130ed5c21a..afd59330b5f1 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -14,7 +14,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 /* To define the outgoing port and to discover the incoming port a regular
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index 837cdddb53f0..d1258e84cd71 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -13,7 +13,7 @@
  */
 
 #include <linux/etherdevice.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 #define MTK_HDR_LEN		4
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index be3b67750ac8..2451007699b7 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -12,7 +12,7 @@
  */
 
 #include <linux/etherdevice.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 #define QCA_HDR_LEN	2
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index aa05e276ea22..7488ab2932ab 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -11,7 +11,7 @@
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <net/dsa.h>
+
 #include "dsa_priv.h"
 
 static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
2.13.0
