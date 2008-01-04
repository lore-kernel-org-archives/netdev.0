From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 7/9][NETNS][IPV6] make mld_max_msf readonly in other namespaces
Date: Fri, 04 Jan 2008 12:12:33 +0100
Message-ID: <20080104111444.687589192@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:19169 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbYADLXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:31 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNT7I184440
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:29 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNTUN5058802
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:29 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BNGTA030086
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:16 GMT
Content-Disposition: inline; filename=make-mld_max_msf-readonly.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mld_max_msf protects the system with a maximum allowed multicast 
source filters. Making this variable per namespace can be potentially
an problem if someone inside a namespace set it to a big value, that
will impact the whole system including other namespaces.

I don't see any benefits to have it per namespace for now, so in order 
to keep a directory entry in a newly created namespace, I make it
read-only when we are not in the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/sysctl_net_ipv6.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -122,6 +122,9 @@ static int ipv6_sysctl_net_init(struct n
     	ipv6_table[5].data = &net->ipv6.sysctl.frags.timeout;
   	ipv6_table[6].data = &net->ipv6.sysctl.frags.secret_interval;
 
+	if (net != &init_net)
+		ipv6_table[7].mode = 0444;
+
 	ipv6_frag_sysctl_init(net);
 
 	net->ipv6.sysctl.bindv6only = 0;

-- 
