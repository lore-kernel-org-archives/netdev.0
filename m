From: Patrick McHardy <kaber@trash.net>
Subject: vlan 05/06: Move device unregistration before lower dev cleanup
Date: Thu,  3 Jul 2008 19:04:48 +0200 (MEST)
Message-ID: <20080703170448.6650.27326.sendpatchset@localhost.localdomain>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Cc: shemminger@vyatta.com, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42860 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbYGCREu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:04:50 -0400
In-Reply-To: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Move device unregistration before lower dev cleanup

Move the unregister_netdevice() call for the VLAN device before cleanup
for the lower device. This is needed by GVRP so it can send a leave
message before the applicant on the lower device is cleaned up.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8f8f9dfb07f7c96492d58488d1aaf670329cc91a
tree 7748d32b10dc9342fe36e5f8259d259494c17641
parent 12ad21b911562368e08dc7166109370130c156c7
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:11:19 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:11:19 +0200

 net/8021q/vlan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b591bfc..8cae2da 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -165,6 +165,8 @@ void unregister_vlan_dev(struct net_device *dev)
 
 	synchronize_net();
 
+	unregister_netdevice(dev);
+
 	/* If the group is now empty, kill off the group. */
 	if (grp->nr_vlans == 0) {
 		if (real_dev->features & NETIF_F_HW_VLAN_RX)
@@ -178,8 +180,6 @@ void unregister_vlan_dev(struct net_device *dev)
 
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
-
-	unregister_netdevice(dev);
 }
 
 static void vlan_transfer_operstate(const struct net_device *dev,
