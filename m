From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: protect for_each_sk_fl_rcu in mem_check with rcu_read_lock_bh
Date: Fri, 8 Nov 2013 19:26:21 +0100
Message-ID: <20131108182621.GA404@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: florent.fourcot@enst-bretagne.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58678 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756614Ab3KHS0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:26:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a suspicious rcu derference warning.

Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_flowlabel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 98fdcc6..e7fb710 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -457,8 +457,10 @@ static int mem_check(struct sock *sk)
 	if (room > FL_MAX_SIZE - FL_MAX_PER_SOCK)
 		return 0;
 
+	rcu_read_lock_bh();
 	for_each_sk_fl_rcu(np, sfl)
 		count++;
+	rcu_read_unlock_bh();
 
 	if (room <= 0 ||
 	    ((count >= FL_MAX_PER_SOCK ||
-- 
1.8.3.1
