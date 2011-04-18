From: David Miller <davem@davemloft.net>
Subject: [PATCH 39/42] netfilter: ip6_tables: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:26 -0700 (PDT)
Message-ID: <20110417.173426.45904414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754072Ab1DRAfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:35:00 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 82A9A24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'target' is set but unused in compat_copy_entry_from_user().

Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/netfilter/ip6_tables.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 5a1c6f2..4c1492f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1578,7 +1578,6 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 			    struct xt_table_info *newinfo, unsigned char *base)
 {
 	struct xt_entry_target *t;
-	struct xt_target *target;
 	struct ip6t_entry *de;
 	unsigned int origsize;
 	int ret, h;
@@ -1600,7 +1599,6 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	}
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_ip6t_get_target(e);
-	target = t->u.kernel.target;
 	xt_compat_target_from_user(t, dstptr, size);
 
 	de->next_offset = e->next_offset - (origsize - *size);
-- 
1.7.4.3

