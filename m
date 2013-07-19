From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 2/2 V2] macvlan fdb replace support
Date: Fri, 19 Jul 2013 17:20:08 +0200
Message-ID: <1374247208-8226-2-git-send-email-tmricht@linux.vnet.ibm.com>
References: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:54993 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760253Ab3GSPUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 11:20:18 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Fri, 19 Jul 2013 16:14:23 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1CA412190056
	for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 16:24:18 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6JFK3h063176714
	for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 15:20:03 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6JFKD6v029703
	for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 09:20:14 -0600
In-Reply-To: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for iproute2 command 'bridge fdb replace ...'.
The rtnletlink call back function ndo_fdb_add will be called
with the NLM_F_REPLACE flag set.
Simply return -EOPNOTSUP.

Resubmitted because net-next was closed last week.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/net/macvlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 18373b6..74907f5 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -597,6 +597,9 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!vlan->port->passthru)
 		return -EOPNOTSUPP;
 
+	if (flags & NLM_F_REPLACE)
+		return -EOPNOTSUPP;
+
 	if (is_unicast_ether_addr(addr))
 		err = dev_uc_add_excl(dev, addr);
 	else if (is_multicast_ether_addr(addr))
-- 
1.8.1.4
