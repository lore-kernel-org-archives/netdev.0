From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v3 4/6] 6lowpan: fix some checkpatch issues
Date: Sat, 22 Feb 2014 16:02:38 +0100
Message-ID: <1393081360-11968-5-git-send-email-alex.aring@gmail.com>
References: <1393081360-11968-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:50413 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaBVPDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 10:03:46 -0500
Received: by mail-ee0-f41.google.com with SMTP id b15so34092eek.0
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 07:03:45 -0800 (PST)
In-Reply-To: <1393081360-11968-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected with:

./scripts/checkpatch.pl --strict -f net/ieee802154/6lowpan_rtnl.c

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Tested-by: Martin Townsend <martin.townsend@xsilon.com>
---
 net/ieee802154/6lowpan_rtnl.c | 27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 0fe0173..ff8907c 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -1,10 +1,8 @@
-/*
- * Copyright 2011, Siemens AG
+/* Copyright 2011, Siemens AG
  * written by Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-/*
- * Based on patches from Jon Smirl <jonsmirl@gmail.com>
+/* Based on patches from Jon Smirl <jonsmirl@gmail.com>
  * Copyright (c) 2011 Jon Smirl <jonsmirl@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -15,10 +13,6 @@
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
  */
 
 /* Jon's code is based on 6lowpan implementation for Contiki which is:
@@ -133,13 +127,11 @@ static int lowpan_header_create(struct sk_buff *skb,
 
 	lowpan_header_compress(skb, dev, type, daddr, saddr, len);
 
-	/*
-	 * NOTE1: I'm still unsure about the fact that compression and WPAN
+	/* NOTE1: I'm still unsure about the fact that compression and WPAN
 	 * header are created here and not later in the xmit. So wait for
 	 * an opinion of net maintainers.
 	 */
-	/*
-	 * NOTE2: to be absolutely correct, we must derive PANid information
+	/* NOTE2: to be absolutely correct, we must derive PANid information
 	 * from MAC subif of the 'dev' and 'real_dev' network devices, but
 	 * this isn't implemented in mainline yet, so currently we assign 0xff
 	 */
@@ -154,8 +146,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 	/* intra-PAN communications */
 	da.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
 
-	/*
-	 * if the destination address is the broadcast address, use the
+	/* if the destination address is the broadcast address, use the
 	 * corresponding short address
 	 */
 	if (lowpan_is_addr_broadcast(daddr)) {
@@ -395,7 +386,7 @@ static int lowpan_set_address(struct net_device *dev, void *p)
 
 static int
 lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
-			int mlen, int plen, int offset, int type)
+		     int mlen, int plen, int offset, int type)
 {
 	struct sk_buff *frag;
 	int hlen;
@@ -484,8 +475,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 		err = lowpan_fragment_xmit(skb, head, header_length, len,
 					   offset, LOWPAN_DISPATCH_FRAGN);
 		if (err) {
-			pr_debug("%s unable to send a subsequent FRAGN packet "
-				 "(tag: %d, offset: %d", __func__, tag, offset);
+			pr_debug("%s unable to send a FRAGN packet. (tag: %d, offset: %d)\n",
+				 __func__, tag, offset);
 			goto exit;
 		}
 
@@ -692,7 +683,7 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	lowpan_dev_info(dev)->fragment_tag = 0;
 	mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
 
-	entry = kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNEL);
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry) {
 		dev_put(real_dev);
 		lowpan_dev_info(dev)->real_dev = NULL;
-- 
1.9.0
