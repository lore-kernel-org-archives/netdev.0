From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/20] net/atm/br2684.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:01 -0800
Message-ID: <601c71cff8923d5cb27c058551485cd7fb9a1576.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1046 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932415AbZLHF5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:12 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/br2684.c |   72 +++++++++++++++++++++++------------------------------
 1 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 188addf..ab0e89f 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -17,7 +17,7 @@
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/ip.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <net/arp.h>
 #include <linux/atm.h>
 #include <linux/atmdev.h>
@@ -28,20 +28,14 @@
 
 #include "common.h"
 
-#ifdef SKB_DEBUG
 static void skb_debug(const struct sk_buff *skb)
 {
+#ifdef SKB_DEBUG
 #define NUM2PRINT 50
-	char buf[NUM2PRINT * 3 + 1];	/* 3 chars per byte */
-	int i = 0;
-	for (i = 0; i < skb->len && i < NUM2PRINT; i++) {
-		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
-	}
-	printk(KERN_DEBUG "br2684: skb: %s\n", buf);
-}
-#else
-#define skb_debug(skb)	do {} while (0)
+	print_hex_dump(KERN_DEBUG, "br2684: skb: ", DUMP_OFFSET,
+		       16, 1, skb->data, min(NUM2PRINT, skb->len, true);
 #endif
+}
 
 #define BR2684_ETHERTYPE_LEN	2
 #define BR2684_PAD_LEN		2
@@ -70,7 +64,7 @@ struct br2684_vcc {
 	struct atm_vcc *atmvcc;
 	struct net_device *device;
 	/* keep old push, pop functions for chaining */
-	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
+	void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb);
 	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
@@ -302,7 +296,8 @@ static int br2684_setfilt(struct atm_vcc *atmvcc, void __user * arg)
 		struct br2684_dev *brdev;
 		read_lock(&devs_lock);
 		brdev = BRPRIV(br2684_find_dev(&fs.ifspec));
-		if (brdev == NULL || list_empty(&brdev->brvccs) || brdev->brvccs.next != brdev->brvccs.prev)	/* >1 VCC */
+		if (brdev == NULL || list_empty(&brdev->brvccs) ||
+		    brdev->brvccs.next != brdev->brvccs.prev)	/* >1 VCC */
 			brvcc = NULL;
 		else
 			brvcc = list_entry_brvcc(brdev->brvccs.next);
@@ -378,29 +373,25 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			__skb_trim(skb, skb->len - 4);
 
 		/* accept packets that have "ipv[46]" in the snap header */
-		if ((skb->len >= (sizeof(llc_oui_ipv4)))
-		    &&
-		    (memcmp
-		     (skb->data, llc_oui_ipv4,
-		      sizeof(llc_oui_ipv4) - BR2684_ETHERTYPE_LEN) == 0)) {
-			if (memcmp
-			    (skb->data + 6, ethertype_ipv6,
-			     sizeof(ethertype_ipv6)) == 0)
+		if ((skb->len >= (sizeof(llc_oui_ipv4))) &&
+		    (memcmp(skb->data, llc_oui_ipv4,
+			    sizeof(llc_oui_ipv4) - BR2684_ETHERTYPE_LEN) == 0)) {
+			if (memcmp(skb->data + 6, ethertype_ipv6,
+				   sizeof(ethertype_ipv6)) == 0)
 				skb->protocol = htons(ETH_P_IPV6);
-			else if (memcmp
-				 (skb->data + 6, ethertype_ipv4,
-				  sizeof(ethertype_ipv4)) == 0)
+			else if (memcmp(skb->data + 6, ethertype_ipv4,
+					sizeof(ethertype_ipv4)) == 0)
 				skb->protocol = htons(ETH_P_IP);
 			else
 				goto error;
 			skb_pull(skb, sizeof(llc_oui_ipv4));
 			skb_reset_network_header(skb);
 			skb->pkt_type = PACKET_HOST;
-			/*
-			 * Let us waste some time for checking the encapsulation.
-			 * Note, that only 7 char is checked so frames with a valid FCS
-			 * are also accepted (but FCS is not checked of course).
-			 */
+		/*
+		 * Let us waste some time for checking the encapsulation.
+		 * Note, that only 7 char is checked so frames with a valid FCS
+		 * are also accepted (but FCS is not checked of course).
+		 */
 		} else if ((skb->len >= sizeof(llc_oui_pid_pad)) &&
 			   (memcmp(skb->data, llc_oui_pid_pad, 7) == 0)) {
 			skb_pull(skb, sizeof(llc_oui_pid_pad));
@@ -495,12 +486,12 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 		err = -EEXIST;
 		goto error;
 	}
-	if (be.fcs_in != BR2684_FCSIN_NO || be.fcs_out != BR2684_FCSOUT_NO ||
-	    be.fcs_auto || be.has_vpiid || be.send_padding || (be.encaps !=
-							       BR2684_ENCAPS_VC
-							       && be.encaps !=
-							       BR2684_ENCAPS_LLC)
-	    || be.min_size != 0) {
+	if (be.fcs_in != BR2684_FCSIN_NO ||
+	    be.fcs_out != BR2684_FCSOUT_NO ||
+	    be.fcs_auto || be.has_vpiid || be.send_padding ||
+	    (be.encaps != BR2684_ENCAPS_VC &&
+	     be.encaps != BR2684_ENCAPS_LLC) ||
+	    be.min_size != 0) {
 		err = -EINVAL;
 		goto error;
 	}
@@ -541,7 +532,8 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	}
 	__module_get(THIS_MODULE);
 	return 0;
-      error:
+
+error:
 	write_unlock_irq(&devs_lock);
 	kfree(brvcc);
 	return err;
@@ -582,7 +574,7 @@ static void br2684_setup_routed(struct net_device *netdev)
 	INIT_LIST_HEAD(&brdev->brvccs);
 }
 
-static int br2684_create(void __user * arg)
+static int br2684_create(void __user *arg)
 {
 	int err;
 	struct net_device *netdev;
@@ -592,9 +584,8 @@ static int br2684_create(void __user * arg)
 
 	pr_debug("\n");
 
-	if (copy_from_user(&ni, arg, sizeof ni)) {
+	if (copy_from_user(&ni, arg, sizeof ni))
 		return -EFAULT;
-	}
 
 	if (ni.media & BR2684_FLAG_ROUTED)
 		payload = p_routed;
@@ -602,9 +593,8 @@ static int br2684_create(void __user * arg)
 		payload = p_bridged;
 	ni.media &= 0xffff;	/* strip flags */
 
-	if (ni.media != BR2684_MEDIA_ETHERNET || ni.mtu != 1500) {
+	if (ni.media != BR2684_MEDIA_ETHERNET || ni.mtu != 1500)
 		return -EINVAL;
-	}
 
 	netdev = alloc_netdev(sizeof(struct br2684_dev),
 			      ni.ifname[0] ? ni.ifname : "nas%d",
-- 
1.6.6.rc0.57.gad7a

