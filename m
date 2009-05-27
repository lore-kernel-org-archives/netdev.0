From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/04: xt_hashlimit does a wrong SEQ_SKIP
Date: Wed, 27 May 2009 16:35:28 +0200 (MEST)
Message-ID: <20090527143526.4649.77396.sendpatchset@x2.localnet>
References: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51327 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759814AbZE0Of2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 10:35:28 -0400
In-Reply-To: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 683a04cebc63819a36b1db19843bd17771f05b55
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Wed May 27 15:45:34 2009 +0200

    netfilter: xt_hashlimit does a wrong SEQ_SKIP
    
    The function dl_seq_show() returns 1 (equal to SEQ_SKIP) in case
    a seq_printf() call return -1.  It should return -1.
    
    This SEQ_SKIP behavior brakes processing the proc file e.g. via a
    pipe or just through less.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index a5b5369..219dcdb 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -926,7 +926,7 @@ static int dl_seq_show(struct seq_file *s, void *v)
 	if (!hlist_empty(&htable->hash[*bucket])) {
 		hlist_for_each_entry(ent, pos, &htable->hash[*bucket], node)
 			if (dl_seq_real_show(ent, htable->family, s))
-				return 1;
+				return -1;
 	}
 	return 0;
 }
