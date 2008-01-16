From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 2/2] [IPV4] fib_trie: fix duplicated route issue
Date: Wed, 16 Jan 2008 20:13:49 +0900
Message-ID: <120048202988-git-send-email-joonwpark81@gmail.com>
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Alexander Zubkov <green@msu.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:35361 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbYAPLNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 06:13:55 -0500
Received: by rv-out-0910.google.com with SMTP id k20so187700rvb.1
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 03:13:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

http://bugzilla.kernel.org/show_bug.cgi?id=9493

The fib allows making identical routes with 'ip route replace'.
This patch makes the fib return -EEXIST if replacement would cause duplication.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/ipv4/fib_trie.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 8d8c291..1010b46 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1214,6 +1214,9 @@ static int fn_trie_insert(struct fib_table *tb, struct fib_config *cfg)
 			struct fib_info *fi_drop;
 			u8 state;
 
+			if (fi->fib_treeref > 1)
+				goto out;
+
 			err = -ENOBUFS;
 			new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
 			if (new_fa == NULL)
-- 
1.5.3.rc5

