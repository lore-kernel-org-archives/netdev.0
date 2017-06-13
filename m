From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 06/10] batman-adv: tp_meter: mark init function with __init
Date: Tue, 13 Jun 2017 13:36:56 +0200
Message-ID: <20170613113700.31220-7-sw@simonwunderlich.de>
References: <20170613113700.31220-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Antonio Quartulli <a@unstable.cc>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43836 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752643AbdFMLhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:10 -0400
In-Reply-To: <20170613113700.31220-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <a@unstable.cc>

batadv_tp_meter_init() is invoked in batadv_init() only
which is marked with __init.

For this reason batadv_tp_meter_init() can be marked with
__init as well and dropped after module load.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/tp_meter.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index 556f9a865ddf..e3e2585d0977 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -27,6 +27,7 @@
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/if_ether.h>
+#include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
 #include <linux/kref.h>
@@ -1497,7 +1498,7 @@ void batadv_tp_meter_recv(struct batadv_priv *bat_priv, struct sk_buff *skb)
 /**
  * batadv_tp_meter_init - initialize global tp_meter structures
  */
-void batadv_tp_meter_init(void)
+void __init batadv_tp_meter_init(void)
 {
 	get_random_bytes(batadv_tp_prerandom, sizeof(batadv_tp_prerandom));
 }
-- 
2.11.0
