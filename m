From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/16] batman-adv: Remove bat_ prefix from bat_{debugfs, sysfs}.{c, h}
Date: Mon,  2 Jul 2012 01:43:42 +0200
Message-ID: <1341186226-10549-13-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23583 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab2GAXnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:42 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The "bat_" prefix in the source files implementing the batman-adv sysfs and
debugfs interface doesn't have a special meaning and are only used by these
files and files that implement the actual B.A.T.M.A.N. path finding algorithm.

The prefix is better suited to mark files that are used to implement the main
part of the path finding. All other files should not use it and therefore gets
renamed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/Makefile                     |    4 ++--
 net/batman-adv/{bat_debugfs.c => debugfs.c} |    2 +-
 net/batman-adv/{bat_debugfs.h => debugfs.h} |    0
 net/batman-adv/gateway_client.c             |    2 +-
 net/batman-adv/hard-interface.c             |    2 +-
 net/batman-adv/main.c                       |    4 ++--
 net/batman-adv/soft-interface.c             |    4 ++--
 net/batman-adv/{bat_sysfs.c => sysfs.c}     |    2 +-
 net/batman-adv/{bat_sysfs.h => sysfs.h}     |    0
 9 files changed, 10 insertions(+), 10 deletions(-)
 rename net/batman-adv/{bat_debugfs.c => debugfs.c} (99%)
 rename net/batman-adv/{bat_debugfs.h => debugfs.h} (100%)
 rename net/batman-adv/{bat_sysfs.c => sysfs.c} (99%)
 rename net/batman-adv/{bat_sysfs.h => sysfs.h} (100%)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 6d5c194..8676d2b 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -19,11 +19,10 @@
 #
 
 obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
-batman-adv-y += bat_debugfs.o
 batman-adv-y += bat_iv_ogm.o
-batman-adv-y += bat_sysfs.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
+batman-adv-y += debugfs.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
@@ -35,6 +34,7 @@ batman-adv-y += ring_buffer.o
 batman-adv-y += routing.o
 batman-adv-y += send.o
 batman-adv-y += soft-interface.o
+batman-adv-y += sysfs.o
 batman-adv-y += translation-table.o
 batman-adv-y += unicast.o
 batman-adv-y += vis.o
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/debugfs.c
similarity index 99%
rename from net/batman-adv/bat_debugfs.c
rename to net/batman-adv/debugfs.c
index acf33e2..e45cf0e 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -21,7 +21,7 @@
 
 #include <linux/debugfs.h>
 
-#include "bat_debugfs.h"
+#include "debugfs.h"
 #include "translation-table.h"
 #include "originator.h"
 #include "hard-interface.h"
diff --git a/net/batman-adv/bat_debugfs.h b/net/batman-adv/debugfs.h
similarity index 100%
rename from net/batman-adv/bat_debugfs.h
rename to net/batman-adv/debugfs.h
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 43b9c17..b421cc4 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -18,7 +18,7 @@
  */
 
 #include "main.h"
-#include "bat_sysfs.h"
+#include "sysfs.h"
 #include "gateway_client.h"
 #include "gateway_common.h"
 #include "hard-interface.h"
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index eb765a7..60f50c5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -23,7 +23,7 @@
 #include "send.h"
 #include "translation-table.h"
 #include "routing.h"
-#include "bat_sysfs.h"
+#include "sysfs.h"
 #include "originator.h"
 #include "hash.h"
 #include "bridge_loop_avoidance.h"
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 17dcdd9..13c88b2 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -18,8 +18,8 @@
  */
 
 #include "main.h"
-#include "bat_sysfs.h"
-#include "bat_debugfs.h"
+#include "sysfs.h"
+#include "debugfs.h"
 #include "routing.h"
 #include "send.h"
 #include "originator.h"
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7a7d821..b7c655c 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -22,12 +22,12 @@
 #include "hard-interface.h"
 #include "routing.h"
 #include "send.h"
-#include "bat_debugfs.h"
+#include "debugfs.h"
 #include "translation-table.h"
 #include "hash.h"
 #include "gateway_common.h"
 #include "gateway_client.h"
-#include "bat_sysfs.h"
+#include "sysfs.h"
 #include "originator.h"
 #include <linux/slab.h>
 #include <linux/ethtool.h>
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/sysfs.c
similarity index 99%
rename from net/batman-adv/bat_sysfs.c
rename to net/batman-adv/sysfs.c
index a0a9ea4..66518c7 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -18,7 +18,7 @@
  */
 
 #include "main.h"
-#include "bat_sysfs.h"
+#include "sysfs.h"
 #include "translation-table.h"
 #include "originator.h"
 #include "hard-interface.h"
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/sysfs.h
similarity index 100%
rename from net/batman-adv/bat_sysfs.h
rename to net/batman-adv/sysfs.h
-- 
1.7.9.4
