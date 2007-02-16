From: Joe Perches <joe@perches.com>
Subject: [PATCH] - drivers/net/hamradio remove local random function, use
	random32()
Date: Thu, 15 Feb 2007 19:36:18 -0800
Message-ID: <1171596978.29021.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, jpr@f6fbb.org, t.sailer@alumni.ethz.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1727 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423098AbXBPDgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 22:36:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove local random function, use random32() instead

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 153b6dc..84aa211 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -52,6 +52,7 @@
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
 #include <linux/jiffies.h>
+#include <linux/random.h>
 #include <net/ax25.h> 
 #include <asm/uaccess.h>
 
@@ -433,16 +434,6 @@ static void encode_hdlc(struct baycom_state *bc)
 
 /* ---------------------------------------------------------------------- */
 
-static unsigned short random_seed;
-
-static inline unsigned short random_num(void)
-{
-	random_seed = 28629 * random_seed + 157;
-	return random_seed;
-}
-
-/* ---------------------------------------------------------------------- */
-
 static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 {
 	struct parport *pp = bc->pdev->port;
@@ -464,7 +455,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 			if ((--bc->hdlctx.slotcnt) > 0)
 				return 0;
 			bc->hdlctx.slotcnt = bc->ch_params.slottime;
-			if ((random_num() % 256) > bc->ch_params.ppersist)
+			if ((random32() % 256) > bc->ch_params.ppersist)
 				return 0;
 		}
 	}
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 452873e..f5a17ad 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -56,6 +56,7 @@
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <linux/hdlcdrv.h>
+#include <linux/random.h>
 #include <net/ax25.h> 
 #include <asm/uaccess.h>
 
@@ -371,16 +372,6 @@ static void start_tx(struct net_device *dev, struct hdlcdrv_state *s)
 
 /* ---------------------------------------------------------------------- */
 
-static unsigned short random_seed;
-
-static inline unsigned short random_num(void)
-{
-	random_seed = 28629 * random_seed + 157;
-	return random_seed;
-}
-
-/* ---------------------------------------------------------------------- */
-
 void hdlcdrv_arbitrate(struct net_device *dev, struct hdlcdrv_state *s)
 {
 	if (!s || s->magic != HDLCDRV_MAGIC || s->hdlctx.ptt || !s->skb) 
@@ -396,7 +387,7 @@ void hdlcdrv_arbitrate(struct net_device *dev, struct hdlcdrv_state *s)
 	if ((--s->hdlctx.slotcnt) > 0)
 		return;
 	s->hdlctx.slotcnt = s->ch_params.slottime;
-	if ((random_num() % 256) > s->ch_params.ppersist)
+	if ((random32() % 256) > s->ch_params.ppersist)
 		return;
 	start_tx(dev, s);
 }
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 6d74f08..efc0bcd 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -50,6 +50,7 @@
 #include <linux/slab.h>
 #include <linux/errno.h>
 #include <linux/bitops.h>
+#include <linux/random.h>
 #include <asm/io.h>
 #include <asm/system.h>
 #include <linux/interrupt.h>
@@ -566,14 +567,6 @@ static void yam_start_tx(struct net_device *dev, struct yam_port *yp)
 	ptt_on(dev);
 }
 
-static unsigned short random_seed;
-
-static inline unsigned short random_num(void)
-{
-	random_seed = 28629 * random_seed + 157;
-	return random_seed;
-}
-
 static void yam_arbitrate(struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
@@ -600,7 +593,7 @@ static void yam_arbitrate(struct net_device *dev)
 	yp->slotcnt = yp->slot / 10;
 
 	/* is random > persist ? */
-	if ((random_num() % 256) > yp->pers)
+	if ((random32() % 256) > yp->pers)
 		return;
 
 	yam_start_tx(dev, yp);


