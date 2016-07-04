From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 06/11] batman-adv: Fix bat_(iv|v) function declaration header
Date: Mon,  4 Jul 2016 15:02:54 +0200
Message-ID: <1467637379-6089-7-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58225 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbcGDNDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:12 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

The bat_algo.h had some functions declared which were not part of the
bat_algo.c file. These are instead stored in bat_v.c and bat_iv_ogm.c. =
The
declaration should therefore be also in bat_v.h and bat_iv_ogm,h to mak=
e
them easier to find.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_algo.h          | 31 -----------------------
 net/batman-adv/bat_iv_ogm.c        |  3 ++-
 net/batman-adv/bat_iv_ogm.h        | 25 ++++++++++++++++++
 net/batman-adv/bat_v.c             |  3 ++-
 net/batman-adv/bat_v.h             | 52 ++++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/hard-interface.c    |  2 +-
 net/batman-adv/main.c              |  2 ++
 net/batman-adv/routing.c           |  1 -
 net/batman-adv/translation-table.c |  1 -
 9 files changed, 84 insertions(+), 36 deletions(-)
 create mode 100644 net/batman-adv/bat_iv_ogm.h
 create mode 100644 net/batman-adv/bat_v.h

diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 8c7e761..860d773 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -24,8 +24,6 @@
=20
 struct seq_file;
=20
-int batadv_iv_init(void);
-
 extern char batadv_routing_algo[];
 extern struct list_head batadv_hardif_list;
=20
@@ -34,33 +32,4 @@ int batadv_algo_register(struct batadv_algo_ops *bat=
_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
=20
-#ifdef CONFIG_BATMAN_ADV_BATMAN_V
-
-int batadv_v_init(void);
-void batadv_v_hardif_init(struct batadv_hard_iface *hardif);
-int batadv_v_mesh_init(struct batadv_priv *bat_priv);
-void batadv_v_mesh_free(struct batadv_priv *bat_priv);
-
-#else
-
-static inline int batadv_v_init(void)
-{
-	return 0;
-}
-
-static inline void batadv_v_hardif_init(struct batadv_hard_iface *hard=
if)
-{
-}
-
-static inline int batadv_v_mesh_init(struct batadv_priv *bat_priv)
-{
-	return 0;
-}
-
-static inline void batadv_v_mesh_free(struct batadv_priv *bat_priv)
-{
-}
-
-#endif /* CONFIG_BATMAN_ADV_BATMAN_V */
-
 #endif /* _NET_BATMAN_ADV_BAT_ALGO_H_ */
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 805532a..e2d8848 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -15,7 +15,7 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
  */
=20
-#include "bat_algo.h"
+#include "bat_iv_ogm.h"
 #include "main.h"
=20
 #include <linux/atomic.h>
@@ -49,6 +49,7 @@
 #include <linux/types.h>
 #include <linux/workqueue.h>
=20
+#include "bat_algo.h"
 #include "bitarray.h"
 #include "hard-interface.h"
 #include "hash.h"
diff --git a/net/batman-adv/bat_iv_ogm.h b/net/batman-adv/bat_iv_ogm.h
new file mode 100644
index 0000000..b9f3550
--- /dev/null
+++ b/net/batman-adv/bat_iv_ogm.h
@@ -0,0 +1,25 @@
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ */
+
+#ifndef _BATMAN_ADV_BATADV_IV_OGM_H_
+#define _BATMAN_ADV_BATADV_IV_OGM_H_
+
+#include "main.h"
+
+int batadv_iv_init(void);
+
+#endif /* _BATMAN_ADV_BATADV_IV_OGM_H_ */
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index c2fea81..7231440 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -15,7 +15,7 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
  */
=20
-#include "bat_algo.h"
+#include "bat_v.h"
 #include "main.h"
=20
 #include <linux/atomic.h>
@@ -31,6 +31,7 @@
 #include <linux/types.h>
 #include <linux/workqueue.h>
=20
+#include "bat_algo.h"
 #include "bat_v_elp.h"
 #include "bat_v_ogm.h"
 #include "hard-interface.h"
diff --git a/net/batman-adv/bat_v.h b/net/batman-adv/bat_v.h
new file mode 100644
index 0000000..83b7763
--- /dev/null
+++ b/net/batman-adv/bat_v.h
@@ -0,0 +1,52 @@
+/* Copyright (C) 2011-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Linus L=C3=BCssing
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
+ */
+
+#ifndef _NET_BATMAN_ADV_BAT_V_H_
+#define _NET_BATMAN_ADV_BAT_V_H_
+
+#include "main.h"
+
+#ifdef CONFIG_BATMAN_ADV_BATMAN_V
+
+int batadv_v_init(void);
+void batadv_v_hardif_init(struct batadv_hard_iface *hardif);
+int batadv_v_mesh_init(struct batadv_priv *bat_priv);
+void batadv_v_mesh_free(struct batadv_priv *bat_priv);
+
+#else
+
+static inline int batadv_v_init(void)
+{
+	return 0;
+}
+
+static inline void batadv_v_hardif_init(struct batadv_hard_iface *hard=
if)
+{
+}
+
+static inline int batadv_v_mesh_init(struct batadv_priv *bat_priv)
+{
+	return 0;
+}
+
+static inline void batadv_v_mesh_free(struct batadv_priv *bat_priv)
+{
+}
+
+#endif /* CONFIG_BATMAN_ADV_BATMAN_V */
+
+#endif /* _NET_BATMAN_ADV_BAT_V_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index ad2c37c..70841c1 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -37,7 +37,7 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
=20
-#include "bat_algo.h"
+#include "bat_v.h"
 #include "bridge_loop_avoidance.h"
 #include "debugfs.h"
 #include "distributed-arp-table.h"
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 05e559c..eab9d1b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -46,6 +46,8 @@
 #include <net/rtnetlink.h>
=20
 #include "bat_algo.h"
+#include "bat_iv_ogm.h"
+#include "bat_v.h"
 #include "bridge_loop_avoidance.h"
 #include "debugfs.h"
 #include "distributed-arp-table.h"
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a5b53a3..5833ab3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -34,7 +34,6 @@
 #include <linux/spinlock.h>
 #include <linux/stddef.h>
=20
-#include "bat_algo.h"
 #include "bitarray.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 53458d6..48ce788 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -44,7 +44,6 @@
 #include <linux/string.h>
 #include <linux/workqueue.h>
=20
-#include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "hash.h"
--=20
2.8.1
