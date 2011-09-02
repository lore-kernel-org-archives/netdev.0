From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Fri, 02 Sep 2011 10:22:21 -0700
Message-ID: <20110902172247.396753508@vyatta.com>
References: <20110902172220.830228928@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:48254 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753906Ab1IBRe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 13:34:28 -0400
Content-Disposition: inline; filename=br-carrier-default.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This resolves a regression seen by some users of bridging.
Some users use the bridge like a dummy device. 
They expect to be able to put an IPv6 address on the device
with no ports attached during boot.

Note: the bridge still will reflect the state of ports in the
bridge if there are any added.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This fix needs to go to stable for 3.0 and 2.6.39


--- a/net/bridge/br_device.c	2011-09-01 08:52:27.596631192 -0700
+++ b/net/bridge/br_device.c	2011-09-01 09:01:03.256611801 -0700
@@ -91,7 +91,6 @@ static int br_dev_open(struct net_device
 {
 	struct net_bridge *br = netdev_priv(dev);
 
-	netif_carrier_off(dev);
 	netdev_update_features(dev);
 	netif_start_queue(dev);
 	br_stp_enable_bridge(br);
@@ -108,8 +107,6 @@ static int br_dev_stop(struct net_device
 {
 	struct net_bridge *br = netdev_priv(dev);
 
-	netif_carrier_off(dev);
-
 	br_stp_disable_bridge(br);
 	br_multicast_stop(br);
 
