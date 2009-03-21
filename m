From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 46/77] x25_asy: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:13 -0700
Message-ID: <20090321053716.027121590@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36645 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760994AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=x25_asy-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/wan/x25_asy.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

--- a/drivers/net/wan/x25_asy.c	2009-03-20 22:03:55.785902240 -0700
+++ b/drivers/net/wan/x25_asy.c	2009-03-20 22:03:57.377902450 -0700
@@ -712,6 +712,14 @@ static int x25_asy_open_dev(struct net_d
 	return 0;
 }
 
+static const struct net_device_ops x25_asy_netdev_ops = {
+	.ndo_open	= x25_asy_open_dev,
+	.ndo_stop	= x25_asy_close,
+	.ndo_start_xmit	= x25_asy_xmit,
+	.ndo_tx_timeout	= x25_asy_timeout,
+	.ndo_change_mtu	= x25_asy_change_mtu,
+};
+
 /* Initialise the X.25 driver.  Called by the device init code */
 static void x25_asy_setup(struct net_device *dev)
 {
@@ -727,12 +735,8 @@ static void x25_asy_setup(struct net_dev
 	 */
 
 	dev->mtu		= SL_MTU;
-	dev->hard_start_xmit	= x25_asy_xmit;
-	dev->tx_timeout		= x25_asy_timeout;
+	dev->netdev_ops		= &x25_asy_netdev_ops;
 	dev->watchdog_timeo	= HZ*20;
-	dev->open		= x25_asy_open_dev;
-	dev->stop		= x25_asy_close;
-	dev->change_mtu		= x25_asy_change_mtu;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->type		= ARPHRD_X25;

-- 

