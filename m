From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 05/21] net: rbridge: adapt Bridge structure
Date: Tue,  1 Sep 2015 17:43:00 +0200
Message-ID: <1441122196-11662-6-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>,
	=?UTF-8?q?Fran=C3=A7ois=20Cachereul?= <f.cachereul@alphalink.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:39105 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752337AbbIAPxk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 11:53:40 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change bridge structure to add corresponding RBridge reference
change bridge port structure to identify disable /P2P/ ACCESS / TRUNK p=
ort/

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_private.h | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8b21146..ff757da 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -20,6 +20,9 @@
 #include <net/route.h>
 #include <net/ip6_fib.h>
 #include <linux/if_vlan.h>
+#ifdef CONFIG_TRILL
+#include "rbr_private.h"
+#endif
=20
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -32,6 +35,19 @@
=20
 #define BR_VERSION	"2.3"
=20
+#ifdef CONFIG_TRILL
+  /* TRILL flagged ports are ports where we expect
+   * receiving native layer 2 frames
+   */
+#define TRILL_FLAG_DISABLE	0x1
+#define TRILL_FLAG_P2P		0x2
+#define TRILL_FLAG_ACCESS	0x4
+#define TRILL_FLAG_TRUNK	0x8	/* DROP ALL native L2 frame */
+/* Bridge TRILL state */
+#define BR_NO_TRILL		0	/* no trill  */
+#define BR_TRILL		1	/* trill enabled */
+#endif
+
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
 /* Don't allow forwarding of control protocols like STP, MAC PAUSE and=
 LACP */
@@ -165,6 +181,11 @@ struct net_bridge_port
 	struct rcu_head			rcu;
=20
 	unsigned long 			flags;
+	/* Trill */
+#ifdef CONFIG_TRILL
+	u8				trill_flag;
+#endif /* CONFIG_TRILL */
+
=20
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_own_query	ip4_own_query;
@@ -248,6 +269,11 @@ struct net_bridge
 		BR_USER_STP,		/* new RSTP in userspace */
 	} stp_enabled;
=20
+#ifdef CONFIG_TRILL
+	bool				trill_enabled;
+	struct rbr			*rbr;
+#endif
+
 	unsigned char			topology_change;
 	unsigned char			topology_change_detected;
=20
--=20
2.1.4
