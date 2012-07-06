From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: fix a bad cast in ip6_dst_lookup_tail()
Date: Fri, 06 Jul 2012 09:19:05 +0200
Message-ID: <1341559145.3265.141.camel@edumazet-glaptop>
References: <1341556907.3265.93.camel@edumazet-glaptop>
	 <20120705.234413.823095842284954048.davem@davemloft.net>
	 <1341557587.3265.107.camel@edumazet-glaptop>
	 <20120706.000341.755169655502291970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50559 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab2GFHTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 03:19:12 -0400
Received: by eeit10 with SMTP id t10so3486580eei.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 00:19:11 -0700 (PDT)
In-Reply-To: <20120706.000341.755169655502291970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix a bug in ip6_dst_lookup_tail(), where typeof(dst) is 
"struct dst_entry **", not "struct dst_entry *"

Reported-by: Fengguang Wu <wfg@linux.intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6d9c0ab..c6af596 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -975,7 +975,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry of the nexthop router
 	 */
 	rcu_read_lock();
-	rt = (struct rt6_info *) dst;
+	rt = (struct rt6_info *) *dst;
 	n = rt->n;
 	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
