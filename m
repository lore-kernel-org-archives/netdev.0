From: dean gaudet <dean@arctic.org>
Subject: Re: [patch] ifb double-counts packets
Date: Sat, 23 Dec 2006 13:58:24 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0612231355290.29784@twinlark.arctic.org>
References: <Pine.LNX.4.64.0612230232410.29784@twinlark.arctic.org>
 <1166880592.3763.3.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:60744 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbWLWV6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Dec 2006 16:58:25 -0500
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1166880592.3763.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Dec 2006, jamal wrote:

> On Sat, 2006-23-12 at 02:35 -0800, dean gaudet wrote:
> > it seems that ifb counts packets twice... both at xmit time and also in 
> > the tasklet.  i'm not sure which one of the two to drop, but here's a 
> > patch for dropping the counting at xmit time.
> 
> Good catch but not quite right. The correct way to do it is to increment
> the rx_ counters instead of tx_ right at the top of  ifb_xmit().
> 
> Do you wanna resubmit your patch with these chmages and hopefully tested
> for your situation?

heh yeah that makes more sense :)

-dean

Signed-off-by: dean gaudet <dean@arctic.org>

Index: linux/drivers/net/ifb.c
===================================================================
--- linux.orig/drivers/net/ifb.c	2006-11-29 13:57:37.000000000 -0800
+++ linux/drivers/net/ifb.c	2006-12-23 13:52:39.000000000 -0800
@@ -154,8 +154,8 @@
 	int ret = 0;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
-	stats->tx_packets++;
-	stats->tx_bytes+=skb->len;
+	stats->rx_packets++;
+	stats->rx_bytes+=skb->len;
 
 	if (!from || !skb->input_dev) {
 dropped:
