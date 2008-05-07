From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] b44: use netstats in net_device structure
Date: Wed, 07 May 2008 23:45:41 +0300
Message-ID: <fvt4dl$rt6$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020004070706010401030102"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:39357 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330AbYEGUpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 16:45:49 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JtqWK-0001XU-9r
	for netdev@vger.kernel.org; Wed, 07 May 2008 20:45:48 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 20:45:48 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 20:45:48 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020004070706010401030102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------020004070706010401030102
Content-Type: text/x-patch;
 name="b44_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="b44_netstats.patch"

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 59dce6a..3d2a525 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -782,7 +782,7 @@ static int b44_rx(struct b44 *bp, int budget)
 		drop_it:
 			b44_recycle_rx(bp, cons, bp->rx_prod);
 		drop_it_no_recycle:
-			bp->stats.rx_dropped++;
+			bp->dev->stats.rx_dropped++;
 			goto next_pkt;
 		}
 
@@ -1643,7 +1643,7 @@ static int b44_close(struct net_device *dev)
 static struct net_device_stats *b44_get_stats(struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
-	struct net_device_stats *nstat = &bp->stats;
+	struct net_device_stats *nstat = &dev->stats;
 	struct b44_hw_stats *hwstat = &bp->hw_stats;
 
 	/* Convert HW stats into netdevice stats. */
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index 7db0c84..ec19875 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -384,7 +384,6 @@ struct b44 {
 
 	struct timer_list	timer;
 
-	struct net_device_stats	stats;
 	struct b44_hw_stats	hw_stats;
 
 	struct ssb_device	*sdev;

--------------020004070706010401030102--

