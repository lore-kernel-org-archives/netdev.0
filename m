From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 181/190] net/sched/sch_htb.c:921:26: warning:
 integer overflow in expression
Date: Sun, 04 Nov 2012 05:48:03 +0800
Message-ID: <50959113.xkJ9zuBEBTS30I+c%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:16485 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab2KCVrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2012 17:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   f7c3f96a41f16865e6422bfb919312a716b16552
commit: 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd [181/190] htb: improved accuracy at high rates
config: make ARCH=mips allmodconfig

All warnings:

net/sched/sch_htb.c: In function 'htb_dequeue':
net/sched/sch_htb.c:921:26: warning: integer overflow in expression [-Woverflow]

vim +921 net/sched/sch_htb.c

^1da177e Linus Torvalds    2005-04-16  905  
^1da177e Linus Torvalds    2005-04-16  906  	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
87990467 Stephen Hemminger 2006-08-10  907  	skb = __skb_dequeue(&q->direct_queue);
87990467 Stephen Hemminger 2006-08-10  908  	if (skb != NULL) {
9190b3b3 Eric Dumazet      2011-01-20  909  ok:
9190b3b3 Eric Dumazet      2011-01-20  910  		qdisc_bstats_update(sch, skb);
fd245a4a Eric Dumazet      2011-01-20  911  		qdisc_unthrottled(sch);
^1da177e Linus Torvalds    2005-04-16  912  		sch->q.qlen--;
^1da177e Linus Torvalds    2005-04-16  913  		return skb;
^1da177e Linus Torvalds    2005-04-16  914  	}
^1da177e Linus Torvalds    2005-04-16  915  
87990467 Stephen Hemminger 2006-08-10  916  	if (!sch->q.qlen)
87990467 Stephen Hemminger 2006-08-10  917  		goto fin;
56b765b7 Vimalkumar        2012-10-31  918  	q->now = ktime_to_ns(ktime_get());
a73be040 Jarek Poplawski   2009-01-12  919  	start_at = jiffies;
^1da177e Linus Torvalds    2005-04-16  920  
56b765b7 Vimalkumar        2012-10-31 @921  	next_event = q->now + 5 * NSEC_PER_SEC;
633fe66e Jarek Poplawski   2008-12-03  922  
^1da177e Linus Torvalds    2005-04-16  923  	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
^1da177e Linus Torvalds    2005-04-16  924  		/* common case optimization - skip event handler quickly */
^1da177e Linus Torvalds    2005-04-16  925  		int m;
fb983d45 Patrick McHardy   2007-03-16  926  		psched_time_t event;
fb983d45 Patrick McHardy   2007-03-16  927  
fb983d45 Patrick McHardy   2007-03-16  928  		if (q->now >= q->near_ev_cache[level]) {
a73be040 Jarek Poplawski   2009-01-12  929  			event = htb_do_events(q, level, start_at);

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
