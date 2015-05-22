From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] ipv4: fill in table id when replacing a route
Date: Fri, 22 May 2015 13:40:09 +0200 (CEST)
Message-ID: <20150522114009.043A6A0CCC@unicorn.suse.cz>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When replacing an IPv4 route, tb_id member of the new fib_alias
structure is not set in the replace code path so that the new route is
ignored.

Fixes: 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/fib_trie.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 64c2076ced54..09b62e17dd8c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1164,6 +1164,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			state = fa->fa_state;
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
+			new_fa->tb_id = tb->tb_id;
 
 			err = netdev_switch_fib_ipv4_add(key, plen, fi,
 							 new_fa->fa_tos,
-- 
2.4.1
