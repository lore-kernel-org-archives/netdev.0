From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 2/2] macvlan fdb replace support
Date: Thu, 11 Jul 2013 12:28:20 +0200
Message-ID: <1373538500-10629-2-git-send-email-tmricht@linux.vnet.ibm.com>
References: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:40185 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab3GKK2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 06:28:33 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Thu, 11 Jul 2013 11:20:32 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 945222190019
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 11:32:22 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6BASHua51445986
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 10:28:17 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6BASSeQ011709
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 04:28:28 -0600
In-Reply-To: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for iproute2 command 'bridge fdb replace ...'.
The rtnletlink call back function ndo_fdb_add will be called
with the NLM_F_REPLACE flag set.
Simply return -EOPNOTSUP.

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
