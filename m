From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 100/106] net/ipv4/inet_hashtables.c:242:21:
 sparse: restricted __portpair degrades to integer
Date: Sun, 02 Dec 2012 02:20:44 +0800
Message-ID: <50ba4a7c.o5mv0SK27e0dxcwD%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17601 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919Ab2LASVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 13:21:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   577b981714b0b3530817569bf705bd74881efc83
commit: ce43b03e8889475817d427b1f3724c7e294b76eb [100/106] net: move inet_dport/inet_num in sock_common


sparse warnings:

+ net/ipv4/inet_hashtables.c:242:21: sparse: restricted __portpair degrades to integer
net/ipv4/inet_hashtables.c:246:29: sparse: restricted __portpair degrades to integer
net/ipv4/inet_hashtables.c:267:21: sparse: restricted __portpair degrades to integer
net/ipv4/inet_hashtables.c:274:29: sparse: restricted __portpair degrades to integer
net/ipv4/inet_hashtables.c:326:21: sparse: restricted __portpair degrades to integer
net/ipv4/inet_hashtables.c:341:21: sparse: restricted __portpair degrades to integer
--
+ net/ipv6/inet6_hashtables.c:92:21: sparse: restricted __portpair degrades to integer
net/ipv6/inet6_hashtables.c:95:29: sparse: restricted __portpair degrades to integer
net/ipv6/inet6_hashtables.c:111:21: sparse: restricted __portpair degrades to integer
net/ipv6/inet6_hashtables.c:117:29: sparse: restricted __portpair degrades to integer
net/ipv6/inet6_hashtables.c:248:21: sparse: restricted __portpair degrades to integer
net/ipv6/inet6_hashtables.c:263:21: sparse: restricted __portpair degrades to integer

vim +242 net/ipv4/inet_hashtables.c

77a5ba55 Pavel Emelyanov 2007-12-20  226  	INET_ADDR_COOKIE(acookie, saddr, daddr)
77a5ba55 Pavel Emelyanov 2007-12-20  227  	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
77a5ba55 Pavel Emelyanov 2007-12-20  228  	struct sock *sk;
3ab5aee7 Eric Dumazet    2008-11-16  229  	const struct hlist_nulls_node *node;
77a5ba55 Pavel Emelyanov 2007-12-20  230  	/* Optimize here for direct hit, only listening connections can
77a5ba55 Pavel Emelyanov 2007-12-20  231  	 * have wildcards anyways.
77a5ba55 Pavel Emelyanov 2007-12-20  232  	 */
9f26b3ad Pavel Emelyanov 2008-06-16  233  	unsigned int hash = inet_ehashfn(net, daddr, hnum, saddr, sport);
f373b53b Eric Dumazet    2009-10-09  234  	unsigned int slot = hash & hashinfo->ehash_mask;
3ab5aee7 Eric Dumazet    2008-11-16  235  	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
77a5ba55 Pavel Emelyanov 2007-12-20  236  
3ab5aee7 Eric Dumazet    2008-11-16  237  	rcu_read_lock();
3ab5aee7 Eric Dumazet    2008-11-16  238  begin:
3ab5aee7 Eric Dumazet    2008-11-16  239  	sk_nulls_for_each_rcu(sk, node, &head->chain) {
ce43b03e Eric Dumazet    2012-11-30  240  		if (sk->sk_hash != hash)
ce43b03e Eric Dumazet    2012-11-30  241  			continue;
ce43b03e Eric Dumazet    2012-11-30 @242  		if (likely(INET_MATCH(sk, net, acookie,
ce43b03e Eric Dumazet    2012-11-30  243  				      saddr, daddr, ports, dif))) {
3ab5aee7 Eric Dumazet    2008-11-16  244  			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
3ab5aee7 Eric Dumazet    2008-11-16  245  				goto begintw;
ce43b03e Eric Dumazet    2012-11-30  246  			if (unlikely(!INET_MATCH(sk, net, acookie,
ce43b03e Eric Dumazet    2012-11-30  247  						 saddr, daddr, ports, dif))) {
3ab5aee7 Eric Dumazet    2008-11-16  248  				sock_put(sk);
3ab5aee7 Eric Dumazet    2008-11-16  249  				goto begin;
3ab5aee7 Eric Dumazet    2008-11-16  250  			}

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
