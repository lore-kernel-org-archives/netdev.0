From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] FIB_TRIE: RCU refine
Date: Thu, 20 Mar 2008 13:15:07 +0800
Message-ID: <47E1F2DB.20204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61705 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752335AbYCTFSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 01:18:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, sorry to send this patch again.
I sent it yesterday, but seems that it was refused by
netdev maillist. I subscribed the mailist and send it
again.

On reader side, RCU list-traversal functions, such as
*list_for_each_entry_rcu(), should be within an RCU
read-side critical section.

Surround them by rcu_read_*lock().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv4/fib_trie.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1ff446d..092e02b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2416,6 +2416,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		seq_indent(seq, iter->depth);
 		seq_printf(seq, "  |-- %d.%d.%d.%d\n", NIPQUAD(val));
 
+		rcu_read_lock();
 		hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
 			struct fib_alias *fa;
 
@@ -2433,6 +2434,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 				seq_putc(seq, '\n');
 			}
 		}
+		rcu_read_unlock();
 	}
 
 	return 0;
-- 
WCN

