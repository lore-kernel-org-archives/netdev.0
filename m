From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 2/3] fix loopback network namespace initialization
Date: Wed, 12 Sep 2007 14:38:13 +0200
Message-ID: <20070912124419.150545693@mai.toulouse-stg.fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:50795 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968405AbXILMqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:46:20 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8CCkICN216450
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:46:18 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CCkIfL2875520
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 13:46:18 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CCkFGK018722
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 13:46:15 +0100
Content-Disposition: inline; filename=net-fix-kernel-bug-dev-nd-net-null.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

The core patchset of the network namespace sent by 
Eric Biederman does not do dynamic loopback creation.
So there is no call to alloc_netdev_mq which fills the
network namespace field of the netdevice.

This patch assign the loopback to the init network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 drivers/net/loopback.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6.24/drivers/net/loopback.c
===================================================================
--- net-2.6.24.orig/drivers/net/loopback.c
+++ net-2.6.24/drivers/net/loopback.c
@@ -225,6 +225,7 @@
 				  | NETIF_F_LLTX
 				  | NETIF_F_NETNS_LOCAL,
 	.ethtool_ops		= &loopback_ethtool_ops,
+	.nd_net                 = &init_net,
 };
 
 /* Setup and register the loopback device. */

-- 
