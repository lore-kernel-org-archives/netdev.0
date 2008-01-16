From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/2][NETNS][DST] add the network namespace pointer in dst_ops
Date: Wed, 16 Jan 2008 15:54:18 +0100
Message-ID: <20080116150733.443636890@localhost.localdomain>
References: <20080116145416.844293640@localhost.localdomain>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:58788 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbYAPPIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 10:08:55 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0GF8suD071056
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:54 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GF8slN2846748
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 16:08:54 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GF8r3b013788
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 16:08:54 +0100
Content-Disposition: inline; filename=add-net-ns-to-dst-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network namespace pointer can be stored into the dst_ops structure.
This is usefull when there are multiple instances of the dst_ops for a
protocol. When there are no several instances, this field will be never
used in the protocol. So there is no impact for the protocols which do
implement the network namespaces.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/dst.h |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6.25-misc/include/net/dst.h
===================================================================
--- net-2.6.25-misc.orig/include/net/dst.h
+++ net-2.6.25-misc/include/net/dst.h
@@ -102,6 +102,7 @@ struct dst_ops
 
 	atomic_t		entries;
 	struct kmem_cache 		*kmem_cachep;
+	struct net              *dst_net;
 };
 
 #ifdef __KERNEL__

-- 
