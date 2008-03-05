From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 3/9][NETNS][IPV6] proc - protect snmp6 from non-init_net calls
Date: Wed, 05 Mar 2008 18:56:52 +0100
Message-ID: <20080305180158.076192781@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:64928 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbYCESCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m25I21vo137368
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I21hN2015268
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:02:01 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I21w4005951
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:01 GMT
Content-Disposition: inline; filename=snmp6-protect-register.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset avoids creation of the /proc entry for snmp6 when
the call is made from a network namespace different from the init_net.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/proc.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-2.6.26/net/ipv6/proc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/proc.c
+++ net-2.6.26/net/ipv6/proc.c
@@ -220,6 +220,9 @@ int snmp6_register_dev(struct inet6_dev 
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
+	if (idev->dev->nd_net != &init_net)
+		return 0;
+
 	if (!proc_net_devsnmp6)
 		return -ENOENT;
 

-- 
