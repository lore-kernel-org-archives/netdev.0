From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/3] net: dsa: include switchdev.h only once
Date: Wed, 17 May 2017 15:46:04 -0400
Message-ID: <20170517194605.31639-3-vivien.didelot@savoirfairelinux.com>
References: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44730 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdEQTsQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 15:48:16 -0400
In-Reply-To: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA drivers and core use switchdev. Include switchdev.h only once, in
the dsa.h public header, so that inclusion in DSA drivers or forward
declarations of switchdev structures in not necessary anymore.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 1 -
 drivers/net/dsa/bcm_sf2.c        | 1 -
 drivers/net/dsa/dsa_loop.c       | 1 -
 drivers/net/dsa/mt7530.c         | 1 -
 drivers/net/dsa/mv88e6xxx/chip.c | 1 -
 drivers/net/dsa/qca8k.c          | 1 -
 include/net/dsa.h                | 7 +------
 net/dsa/slave.c                  | 1 -
 8 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 658a12c888a8..fbc3eb17c7a3 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -29,7 +29,6 @@
 #include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
 #include <net/dsa.h>
-#include <net/switchdev.h>
 
 #include "b53_regs.h"
 #include "b53_priv.h"
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 215d41c1e71f..687a8bae5d73 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -28,7 +28,6 @@
 #include <linux/if_bridge.h>
 #include <linux/brcmphy.h>
 #include <linux/etherdevice.h>
-#include <net/switchdev.h>
 #include <linux/platform_data/b53.h>
 
 #include "bcm_sf2.h"
diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index a19e1781e9bb..6afab16d13dd 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -17,7 +17,6 @@
 #include <linux/workqueue.h>
 #include <linux/module.h>
 #include <linux/if_bridge.h>
-#include <net/switchdev.h>
 #include <net/dsa.h>
 
 #include "dsa_loop.h"
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index b070c167e70f..1bcbe15870ed 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -28,7 +28,6 @@
 #include <linux/reset.h>
 #include <linux/gpio/consumer.h>
 #include <net/dsa.h>
-#include <net/switchdev.h>
 
 #include "mt7530.h"
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d034d8cd7d22..386d878569ed 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -32,7 +32,6 @@
 #include <linux/gpio/consumer.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
-#include <net/switchdev.h>
 
 #include "mv88e6xxx.h"
 #include "global1.h"
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 942b9ac7f92a..149f109dbffb 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -18,7 +18,6 @@
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <net/dsa.h>
-#include <net/switchdev.h>
 #include <linux/of_net.h>
 #include <linux/of_platform.h>
 #include <linux/if_bridge.h>
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 118a8bd2fd9a..61984895a9ad 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -20,6 +20,7 @@
 #include <linux/of.h>
 #include <linux/ethtool.h>
 #include <net/devlink.h>
+#include <net/switchdev.h>
 
 struct tc_action;
 struct phy_device;
@@ -284,12 +285,6 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 		return ds->rtable[dst->cpu_dp->ds->index];
 }
 
-struct switchdev_trans;
-struct switchdev_obj;
-struct switchdev_obj_port_fdb;
-struct switchdev_obj_port_mdb;
-struct switchdev_obj_port_vlan;
-
 #define DSA_NOTIFIER_BRIDGE_JOIN		1
 #define DSA_NOTIFIER_BRIDGE_LEAVE		2
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index fb13c5d7d587..91236d602301 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -18,7 +18,6 @@
 #include <linux/mdio.h>
 #include <linux/list.h>
 #include <net/rtnetlink.h>
-#include <net/switchdev.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
 #include <linux/if_bridge.h>
-- 
2.13.0
