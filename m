From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 3/4] netfilter: ipset: use list_is_first()
Date: Thu, 10 Dec 2015 22:17:17 +0800
Message-ID: <b415535e3c9784ee8529b3e7372b94e759b48bf4.1449755818.git.geliangtang@163.com>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, Jens Axboe <axboe@kernel.dk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:34674 "EHLO m50-133.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbbLJOTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 09:19:48 -0500
In-Reply-To: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
In-Reply-To: <394e9e5ece944969fe1ff4f37c9a73bf5543265e.1449755818.git.geliangtang@163.com>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com> <394e9e5ece944969fe1ff4f37c9a73bf5543265e.1449755818.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For better readability, use list_is_first() instead of open-coded.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/netfilter/ipset/ip_set_list_set.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index bbede95..9d757d6 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -288,7 +288,7 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			n = list_next_entry(next, list);
 	} else {
 		/* Insert before prev element */
-		if (prev->list.prev != &map->members)
+		if (!list_is_first(&prev->list, &map->members))
 			n = list_prev_entry(prev, list);
 	}
 	/* Can we replace a timed out entry? */
-- 
2.5.0
