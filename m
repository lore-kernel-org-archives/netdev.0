From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] bridge: notifier called with the wrong device
Date: Fri, 22 Jul 2011 10:47:08 -0700
Message-ID: <20110722174758.036523438@vyatta.com>
References: <20110722174705.144993799@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davmeloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46800 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab1GVRur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 13:50:47 -0400
Content-Disposition: inline; filename=br-notify-wrong-dev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a new device is added to a bridge, the ethernet address of the
bridge network device may change. When the address changes, the
appropriate callback is called, but with the wrong device argument.
The address of the bridge device (ie br0) changes not the address
of the device being passed to add_if (ie eth0).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next. Should go to stable.


--- a/net/bridge/br_if.c	2011-07-21 20:13:13.539989381 -0700
+++ b/net/bridge/br_if.c	2011-07-21 20:23:12.091989045 -0700
@@ -388,7 +388,7 @@ int br_add_if(struct net_bridge *br, str
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (changed_addr)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
 


