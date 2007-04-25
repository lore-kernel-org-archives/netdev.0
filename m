From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] bridge: missing rtnl
Date: Wed, 25 Apr 2007 16:47:41 -0700
Message-ID: <20070425234950.847694502@linux-foundation.org>
References: <20070425234737.727790594@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:51419 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2993142AbXDYXzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:55:35 -0400
Content-Disposition: inline; filename=br-sysfs-rtnl.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Writing to /sys/class/net/brX/bridge/stp_state causes a warning because
RTNL is not held when call br_stp_if.c

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/bridge/br_sysfs_br.c |    2 ++
 1 file changed, 2 insertions(+)

--- bridge-2.6.22.orig/net/bridge/br_sysfs_br.c
+++ bridge-2.6.22/net/bridge/br_sysfs_br.c
@@ -149,9 +149,11 @@ static ssize_t show_stp_state(struct dev
 
 static void set_stp_state(struct net_bridge *br, unsigned long val)
 {
+	rtnl_lock();
 	spin_unlock_bh(&br->lock);
 	br_stp_set_enabled(br, val);
 	spin_lock_bh(&br->lock);
+	rtnl_unlock();
 }
 
 static ssize_t store_stp_state(struct device *d,

-- 

