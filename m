From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH] Bonding Remove debug_fs files when module init fails
Date: Wed,  9 Apr 2014 12:52:59 +0200
Message-ID: <1397040779-8699-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:56683 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826AbaDIKxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 06:53:06 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Wed, 9 Apr 2014 11:53:05 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id BA39C2190041
	for <netdev@vger.kernel.org>; Wed,  9 Apr 2014 11:52:55 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s39Aqshc4587864
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2014 10:52:54 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s39Br1R2024989
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2014 05:53:01 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the bonding debug_fs entries when the
module initialization fails. The debug_fs
entries should be removed together with all other
already allocated resources.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 95a6ca7..c11e7b7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4492,6 +4492,7 @@ static int __init bonding_init(void)
 out:
 	return res;
 err:
+	bond_destroy_debugfs();
 	bond_netlink_fini();
 err_link:
 	unregister_pernet_subsys(&bond_net_ops);
-- 
1.9.0
