From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/07: xt_quota: fix incomplete initialization
Date: Mon, 22 Jun 2009 14:53:56 +0200 (MEST)
Message-ID: <20090622125356.6531.22320.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39243 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZFVMxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 08:53:54 -0400
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6d62182fea6cc6bbc8d82a691ad0608d68a54aeb
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jun 22 14:16:45 2009 +0200

    netfilter: xt_quota: fix incomplete initialization
    
    Commit v2.6.29-rc5-872-gacc738f ("xtables: avoid pointer to self")
    forgot to copy the initial quota value supplied by iptables into the
    private structure, thus counting from whatever was in the memory
    kmalloc returned.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 01dd07b..98fc190 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -54,6 +54,7 @@ static bool quota_mt_check(const struct xt_mtchk_param *par)
 	if (q->master == NULL)
 		return -ENOMEM;
 
+	q->master->quota = q->quota;
 	return true;
 }
 
