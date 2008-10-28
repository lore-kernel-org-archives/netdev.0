From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/2] veth:  Remove useless veth field
Date: Tue, 28 Oct 2008 22:11:43 +0100
Message-ID: <20081028212115.952319593@fr.ibm.com>
References: <20081028211142.359911603@fr.ibm.com>
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:44038 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbYJ1VV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:21:27 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m9SLLOEG206666
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:24 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SLLOQQ4350164
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:24 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SLLN3m012985
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:23 GMT
Content-Disposition: inline; filename=remove-useless-veth-field.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The veth private structure contains a netdev pointer refering to its peer.
This field is never used and it is pointless because if we can access,
the veth_priv, that means we already have the netdev which is stored
in veth_priv->dev.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 drivers/net/veth.c |    3 ---
 1 file changed, 3 deletions(-)

Index: net-2.6/drivers/net/veth.c
===================================================================
--- net-2.6.orig/drivers/net/veth.c
+++ net-2.6/drivers/net/veth.c
@@ -30,7 +30,6 @@ struct veth_net_stats {
 
 struct veth_priv {
 	struct net_device *peer;
-	struct net_device *dev;
 	struct list_head list;
 	struct veth_net_stats *stats;
 	unsigned ip_summed;
@@ -420,12 +419,10 @@ static int veth_newlink(struct net_devic
 	 */
 
 	priv = netdev_priv(dev);
-	priv->dev = dev;
 	priv->peer = peer;
 	list_add(&priv->list, &veth_list);
 
 	priv = netdev_priv(peer);
-	priv->dev = peer;
 	priv->peer = dev;
 	INIT_LIST_HEAD(&priv->list);
 	return 0;

-- 
