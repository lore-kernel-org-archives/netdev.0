From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/3] ipvs: remove unused variable
Date: Mon, 10 Apr 2017 09:58:35 -0700
Message-ID: <1491843515-1627-4-git-send-email-horms@verge.net.au>
References: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>,
        Arushi Singhal <arushisinghal19971997@gmail.com>,
        Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38715 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755229AbdDJQ7O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 12:59:14 -0400
In-Reply-To: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arushi Singhal <arushisinghal19971997@gmail.com>

This patch uses the following coccinelle script to remove
a variable that was simply used to store the return
value of a function call before returning it:

@@
identifier len,f;
@@

-int len;
 ... when != len
     when strict
-len =
+return
        f(...);
-return len;

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 2e2bf7428cd1..6caf4459e981 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -482,11 +482,8 @@ static struct pernet_operations ip_vs_ftp_ops = {
 
 static int __init ip_vs_ftp_init(void)
 {
-	int rv;
-
-	rv = register_pernet_subsys(&ip_vs_ftp_ops);
 	/* rcu_barrier() is called by netns on error */
-	return rv;
+	return register_pernet_subsys(&ip_vs_ftp_ops);
 }
 
 /*
-- 
2.7.0.rc3.207.g0ac5344
