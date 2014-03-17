From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: conntrack: Fix UP builds
Date: Mon, 17 Mar 2014 13:37:53 -0700
Message-ID: <1395088673.9668.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:38057 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaCQUhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 16:37:55 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so6171367pbc.16
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 13:37:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ARRAY_SIZE(nf_conntrack_locks) is undefined if spinlock_t is an
empty structure. Replace it by CONNTRACK_LOCKS

Fixes: 93bb0ceb75be ("netfilter: conntrack: remove central spinlock nf_conntrack_lock")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
David, you might merge this asap instead of going through Pablo queue ?

 net/netfilter/nf_conntrack_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5d1e7d126ebd..6dba48efe01e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1674,7 +1674,7 @@ int nf_conntrack_init_start(void)
 	int max_factor = 8;
 	int i, ret, cpu;
 
-	for (i = 0; i < ARRAY_SIZE(nf_conntrack_locks); i++)
+	for (i = 0; i < CONNTRACK_LOCKS; i++)
 		spin_lock_init(&nf_conntrack_locks[i]);
 
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
