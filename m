From: dean gaudet <dean@arctic.org>
Subject: [patch] ifb double-counts packets
Date: Sat, 23 Dec 2006 02:35:50 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0612230232410.29784@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:58976 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbWLWKmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Dec 2006 05:42:32 -0500
To: Jamal Hadi Salim <hadi@znyx.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

it seems that ifb counts packets twice... both at xmit time and also in 
the tasklet.  i'm not sure which one of the two to drop, but here's a 
patch for dropping the counting at xmit time.

patch against 2.6.20-rc1.

-dean

Signed-off-by: dean gaudet <dean@arctic.org>

Index: linux/drivers/net/ifb.c
===================================================================
--- linux.orig/drivers/net/ifb.c	2006-11-29 13:57:37.000000000 -0800
+++ linux/drivers/net/ifb.c	2006-12-23 02:14:31.000000000 -0800
@@ -154,9 +154,6 @@
 	int ret = 0;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
-	stats->tx_packets++;
-	stats->tx_bytes+=skb->len;
-
 	if (!from || !skb->input_dev) {
 dropped:
 		dev_kfree_skb(skb);
