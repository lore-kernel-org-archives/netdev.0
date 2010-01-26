From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/21] net/atm/clip.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:05 -0800
Message-ID: <53855e91770da2eabcda05d1194dedb006ff61e0.1264541549.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1479 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0AZVkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:23 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert #include <asm... to #include <linux...
Spacing cleanups
Move labels to column 1
Move logical continuation tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/clip.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index d7939fd..ebfa022 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -32,10 +32,10 @@
 #include <linux/jhash.h>
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
-#include <asm/param.h> /* for HZ */
+#include <linux/param.h> /* for HZ */
+#include <linux/uaccess.h>
 #include <asm/byteorder.h> /* for htons etc. */
 #include <asm/system.h> /* save/restore_flags */
-#include <asm/uaccess.h>
 #include <asm/atomic.h>
 
 #include "common.h"
@@ -56,10 +56,10 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 	pr_debug("(%d)\n", type);
 	if (!atmarpd)
 		return -EUNATCH;
-	skb = alloc_skb(sizeof(struct atmarp_ctrl),GFP_ATOMIC);
+	skb = alloc_skb(sizeof(struct atmarp_ctrl), GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
-	ctrl = (struct atmarp_ctrl *) skb_put(skb,sizeof(struct atmarp_ctrl));
+	ctrl = (struct atmarp_ctrl *)skb_put(skb, sizeof(struct atmarp_ctrl));
 	ctrl->type = type;
 	ctrl->itf_num = itf;
 	ctrl->ip = ip;
@@ -111,7 +111,7 @@ static void unlink_clip_vcc(struct clip_vcc *clip_vcc)
 			goto out;
 		}
 	pr_crit("ATMARP: failed (entry %p, vcc 0x%p)\n", entry, clip_vcc);
-      out:
+out:
 	netif_tx_unlock_bh(entry->neigh->dev);
 }
 
@@ -205,12 +205,12 @@ static void clip_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	}
 	ATM_SKB(skb)->vcc = vcc;
 	skb_reset_mac_header(skb);
-	if (!clip_vcc->encap
-	    || skb->len < RFC1483LLC_LEN
-	    || memcmp(skb->data, llc_oui, sizeof (llc_oui)))
+	if (!clip_vcc->encap ||
+	    skb->len < RFC1483LLC_LEN ||
+	    memcmp(skb->data, llc_oui, sizeof(llc_oui)))
 		skb->protocol = htons(ETH_P_IP);
 	else {
-		skb->protocol = ((__be16 *) skb->data)[3];
+		skb->protocol = ((__be16 *)skb->data)[3];
 		skb_pull(skb, RFC1483LLC_LEN);
 		if (skb->protocol == htons(ETH_P_ARP)) {
 			skb->dev->stats.rx_packets++;
@@ -644,7 +644,6 @@ static int clip_inet_event(struct notifier_block *this, unsigned long event,
 	return clip_device_event(this, NETDEV_CHANGE, in_dev->dev);
 }
 
-
 static struct notifier_block clip_dev_notifier = {
 	.notifier_call = clip_device_event,
 };
@@ -670,7 +669,6 @@ static void atmarpd_close(struct atm_vcc *vcc)
 	module_put(THIS_MODULE);
 }
 
-
 static struct atmdev_ops atmarpd_dev_ops = {
 	.close = atmarpd_close
 };
@@ -692,11 +690,11 @@ static int atm_init_atmarp(struct atm_vcc *vcc)
 		return -EADDRINUSE;
 	}
 
-	mod_timer(&idle_timer, jiffies+CLIP_CHECK_INTERVAL*HZ);
+	mod_timer(&idle_timer, jiffies + CLIP_CHECK_INTERVAL * HZ);
 
 	atmarpd = vcc;
-	set_bit(ATM_VF_META,&vcc->flags);
-	set_bit(ATM_VF_READY,&vcc->flags);
+	set_bit(ATM_VF_META, &vcc->flags);
+	set_bit(ATM_VF_READY, &vcc->flags);
 	    /* allow replies and avoid getting closed if signaling dies */
 	vcc->dev = &atmarpd_dev;
 	vcc_insert_socket(sk_atm(vcc));
-- 
1.6.6.rc0.57.gad7a

