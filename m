From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] [IPv6]: use container_of() macro in fib6_clean_node()
Date: Mon, 08 Oct 2007 18:33:16 +0200
Message-ID: <20071008163316.16798.19433.stgit@frecb000701.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:39349 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbXJHQdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 12:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In ip6_fib.c, fib6_clean_node() casts a fib6_walker_t pointer to
a fib6_cleaner_t pointer assuming a struct fib6_walker_t (field 'w')
is the first field in struct fib6_walker_t.

To prevent any future problems that may occur if one day a field
is inadvertently inserted before the 'w' field in struct fib6_cleaner_t,
(and to improve readability), this patch uses the container_of() macro.

Patch for net-2.6.24

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---

 net/ipv6/ip6_fib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 6a612a7..946cf38 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1313,7 +1313,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 {
 	int res;
 	struct rt6_info *rt;
-	struct fib6_cleaner_t *c = (struct fib6_cleaner_t*)w;
+	struct fib6_cleaner_t *c = container_of(w, struct fib6_cleaner_t, w);
 
 	for (rt = w->leaf; rt; rt = rt->u.dst.rt6_next) {
 		res = c->func(rt, c->arg);

