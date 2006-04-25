From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] sky2: use ALIGN() macro
Date: Tue, 25 Apr 2006 10:58:52 -0700
Message-ID: <20060425175951.868574000@localhost.localdomain>
References: <20060425175849.372221000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31361 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932305AbWDYVCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 17:02:40 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-align.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ALIGN() macro in kernel.h does the same math that the
sky2 driver was using for padding.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2-2.6.17.orig/drivers/net/sky2.c	2006-04-25 10:47:03.000000000 -0700
+++ sky2-2.6.17/drivers/net/sky2.c	2006-04-25 10:47:28.000000000 -0700
@@ -925,8 +925,7 @@
 	skb = alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
 	if (likely(skb)) {
 		unsigned long p	= (unsigned long) skb->data;
-		skb_reserve(skb,
-			((p + RX_SKB_ALIGN - 1) & ~(RX_SKB_ALIGN - 1)) - p);
+		skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
 	}
 
 	return skb;
@@ -1686,13 +1685,12 @@
 }
 
 
-#define roundup(x, y)   ((((x)+((y)-1))/(y))*(y))
 /* Want receive buffer size to be multiple of 64 bits
  * and incl room for vlan and truncation
  */
 static inline unsigned sky2_buf_size(int mtu)
 {
-	return roundup(mtu + ETH_HLEN + VLAN_HLEN, 8) + 8;
+	return ALIGN(mtu + ETH_HLEN + VLAN_HLEN, 8) + 8;
 }
 
 static int sky2_change_mtu(struct net_device *dev, int new_mtu)

--

