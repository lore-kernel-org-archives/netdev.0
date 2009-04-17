From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/02: nfnetlink: return ENOMEM if we fail to create netlink socket
Date: Fri, 17 Apr 2009 18:09:16 +0200 (MEST)
Message-ID: <20090417160915.32484.84220.sendpatchset@x2.localnet>
References: <20090417160913.32484.93063.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56950 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757093AbZDQQJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:09:17 -0400
In-Reply-To: <20090417160913.32484.93063.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a0142733a7ef2f3476e63938b330026a08c53f37
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Fri Apr 17 17:48:44 2009 +0200

    netfilter: nfnetlink: return ENOMEM if we fail to create netlink socket
    
    With this patch, nfnetlink returns -ENOMEM instead of -EPERM if we
    fail to create the nfnetlink netlink socket during the module
    loading. This is exactly what rtnetlink does in this case.
    
    Ideally, it would be better if we propagate the error that has
    happened in netlink_kernel_create(), however, this function still
    does not implement this yet.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 2785d66..b8ab37a 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -203,7 +203,7 @@ static int __init nfnetlink_init(void)
 				     nfnetlink_rcv, NULL, THIS_MODULE);
 	if (!nfnl) {
 		printk(KERN_ERR "cannot initialize nfnetlink!\n");
-		return -1;
+		return -ENOMEM;
 	}
 
 	return 0;
