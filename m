From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/1] 8021q: transfer dev_id from real device
Date: Mon, 08 Oct 2007 17:05:05 +0200
Message-ID: <20071008150820.837583000@linux.vnet.ibm.com>
References: <20071008150504.855164000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:45199 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686AbXJHPIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 11:08:23 -0400
Content-Disposition: inline; filename=8021q-vlan.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

A net_device struct provides field dev_id. It is used for
unique ipv6 generation in case of shared network cards
(as for the OSA network cards of IBM System z). 
If VLAN devices are built on top of such shared network cards,
this dev_id information needs to be transferred to the VLAN device.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---
 net/8021q/vlan.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-2.6.24-uschi/net/8021q/vlan.c
===================================================================
--- net-2.6.24-uschi.orig/net/8021q/vlan.c
+++ net-2.6.24-uschi/net/8021q/vlan.c
@@ -331,6 +331,9 @@ static int vlan_dev_init(struct net_devi
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
+	/* ipv6 shared card related stuff */
+	dev->dev_id = real_dev->dev_id;
+
 	if (is_zero_ether_addr(dev->dev_addr))
 		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
 	if (is_zero_ether_addr(dev->broadcast))

-- 
