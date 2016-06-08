From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 105/106] DockBook: net/core/gen_stats.c:168:
 warning: No description found for parameter 'running'
Date: Wed, 8 Jun 2016 09:31:04 +0800
Message-ID: <201606080958.8AC0tk5K%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:63873 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755086AbcFHBpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 21:45:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   34fe76abbea5174e532681e420fb31139909efb4
commit: edb09eb17ed89eaa82a52dd306beac93e292b485 [105/106] net: sched: do not acquire qdisc spinlock in qdisc/class stats dump
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   include/linux/skbuff.h:930: warning: No description found for parameter 'sk'
   include/net/sock.h:449: warning: No description found for parameter 'sk_padding'
   include/net/sock.h:449: warning: No description found for parameter 'sk_rcu'
   net/core/gen_stats.c:66: warning: No description found for parameter 'padattr'
   net/core/gen_stats.c:102: warning: No description found for parameter 'padattr'
>> net/core/gen_stats.c:168: warning: No description found for parameter 'running'
   include/linux/netdevice.h:1867: warning: No description found for parameter 'qdisc_running_key'

vim +/running +168 net/core/gen_stats.c

^1da177e Linus Torvalds      2005-04-16   60   */
^1da177e Linus Torvalds      2005-04-16   61  int
^1da177e Linus Torvalds      2005-04-16   62  gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
9854518e Nicolas Dichtel     2016-04-26   63  			     int xstats_type, spinlock_t *lock,
9854518e Nicolas Dichtel     2016-04-26   64  			     struct gnet_dump *d, int padattr)
9a429c49 Eric Dumazet        2008-01-01   65  	__acquires(lock)
^1da177e Linus Torvalds      2005-04-16  @66  {
^1da177e Linus Torvalds      2005-04-16   67  	memset(d, 0, sizeof(*d));
^1da177e Linus Torvalds      2005-04-16   68  
^1da177e Linus Torvalds      2005-04-16   69  	if (type)
1e90474c Patrick McHardy     2008-01-22   70  		d->tail = (struct nlattr *)skb_tail_pointer(skb);
^1da177e Linus Torvalds      2005-04-16   71  	d->skb = skb;
^1da177e Linus Torvalds      2005-04-16   72  	d->compat_tc_stats = tc_stats_type;
^1da177e Linus Torvalds      2005-04-16   73  	d->compat_xstats = xstats_type;
9854518e Nicolas Dichtel     2016-04-26   74  	d->padattr = padattr;
edb09eb1 Eric Dumazet        2016-06-06   75  	if (lock) {
edb09eb1 Eric Dumazet        2016-06-06   76  		d->lock = lock;
edb09eb1 Eric Dumazet        2016-06-06   77  		spin_lock_bh(lock);
edb09eb1 Eric Dumazet        2016-06-06   78  	}
^1da177e Linus Torvalds      2005-04-16   79  	if (d->tail)
9854518e Nicolas Dichtel     2016-04-26   80  		return gnet_stats_copy(d, type, NULL, 0, padattr);
^1da177e Linus Torvalds      2005-04-16   81  
^1da177e Linus Torvalds      2005-04-16   82  	return 0;
^1da177e Linus Torvalds      2005-04-16   83  }
9e34a5b5 Eric Dumazet        2010-07-09   84  EXPORT_SYMBOL(gnet_stats_start_copy_compat);
^1da177e Linus Torvalds      2005-04-16   85  
^1da177e Linus Torvalds      2005-04-16   86  /**
9854518e Nicolas Dichtel     2016-04-26   87   * gnet_stats_start_copy - start dumping procedure in compatibility mode
^1da177e Linus Torvalds      2005-04-16   88   * @skb: socket buffer to put statistics TLVs into
^1da177e Linus Torvalds      2005-04-16   89   * @type: TLV type for top level statistic TLV
^1da177e Linus Torvalds      2005-04-16   90   * @lock: statistics lock
^1da177e Linus Torvalds      2005-04-16   91   * @d: dumping handle
^1da177e Linus Torvalds      2005-04-16   92   *
^1da177e Linus Torvalds      2005-04-16   93   * Initializes the dumping handle, grabs the statistic lock and appends
^1da177e Linus Torvalds      2005-04-16   94   * an empty TLV header to the socket buffer for use a container for all
^1da177e Linus Torvalds      2005-04-16   95   * other statistic TLVS.
^1da177e Linus Torvalds      2005-04-16   96   *
^1da177e Linus Torvalds      2005-04-16   97   * Returns 0 on success or -1 if the room in the socket buffer was not sufficient.
^1da177e Linus Torvalds      2005-04-16   98   */
^1da177e Linus Torvalds      2005-04-16   99  int
^1da177e Linus Torvalds      2005-04-16  100  gnet_stats_start_copy(struct sk_buff *skb, int type, spinlock_t *lock,
9854518e Nicolas Dichtel     2016-04-26  101  		      struct gnet_dump *d, int padattr)
^1da177e Linus Torvalds      2005-04-16  102  {
9854518e Nicolas Dichtel     2016-04-26  103  	return gnet_stats_start_copy_compat(skb, type, 0, 0, lock, d, padattr);
^1da177e Linus Torvalds      2005-04-16  104  }
9e34a5b5 Eric Dumazet        2010-07-09  105  EXPORT_SYMBOL(gnet_stats_start_copy);
^1da177e Linus Torvalds      2005-04-16  106  
22e0f8b9 John Fastabend      2014-09-28  107  static void
22e0f8b9 John Fastabend      2014-09-28  108  __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
22e0f8b9 John Fastabend      2014-09-28  109  			    struct gnet_stats_basic_cpu __percpu *cpu)
22e0f8b9 John Fastabend      2014-09-28  110  {
22e0f8b9 John Fastabend      2014-09-28  111  	int i;
22e0f8b9 John Fastabend      2014-09-28  112  
22e0f8b9 John Fastabend      2014-09-28  113  	for_each_possible_cpu(i) {
22e0f8b9 John Fastabend      2014-09-28  114  		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(cpu, i);
22e0f8b9 John Fastabend      2014-09-28  115  		unsigned int start;
02c0fc1b WANG Cong           2014-10-06  116  		u64 bytes;
02c0fc1b WANG Cong           2014-10-06  117  		u32 packets;
22e0f8b9 John Fastabend      2014-09-28  118  
22e0f8b9 John Fastabend      2014-09-28  119  		do {
22e0f8b9 John Fastabend      2014-09-28  120  			start = u64_stats_fetch_begin_irq(&bcpu->syncp);
22e0f8b9 John Fastabend      2014-09-28  121  			bytes = bcpu->bstats.bytes;
22e0f8b9 John Fastabend      2014-09-28  122  			packets = bcpu->bstats.packets;
22e0f8b9 John Fastabend      2014-09-28  123  		} while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));
22e0f8b9 John Fastabend      2014-09-28  124  
02c0fc1b WANG Cong           2014-10-06  125  		bstats->bytes += bytes;
02c0fc1b WANG Cong           2014-10-06  126  		bstats->packets += packets;
22e0f8b9 John Fastabend      2014-09-28  127  	}
22e0f8b9 John Fastabend      2014-09-28  128  }
22e0f8b9 John Fastabend      2014-09-28  129  
22e0f8b9 John Fastabend      2014-09-28  130  void
edb09eb1 Eric Dumazet        2016-06-06  131  __gnet_stats_copy_basic(const seqcount_t *running,
edb09eb1 Eric Dumazet        2016-06-06  132  			struct gnet_stats_basic_packed *bstats,
22e0f8b9 John Fastabend      2014-09-28  133  			struct gnet_stats_basic_cpu __percpu *cpu,
22e0f8b9 John Fastabend      2014-09-28  134  			struct gnet_stats_basic_packed *b)
22e0f8b9 John Fastabend      2014-09-28  135  {
edb09eb1 Eric Dumazet        2016-06-06  136  	unsigned int seq;
edb09eb1 Eric Dumazet        2016-06-06  137  
22e0f8b9 John Fastabend      2014-09-28  138  	if (cpu) {
22e0f8b9 John Fastabend      2014-09-28  139  		__gnet_stats_copy_basic_cpu(bstats, cpu);
edb09eb1 Eric Dumazet        2016-06-06  140  		return;
edb09eb1 Eric Dumazet        2016-06-06  141  	}
edb09eb1 Eric Dumazet        2016-06-06  142  	do {
edb09eb1 Eric Dumazet        2016-06-06  143  		if (running)
edb09eb1 Eric Dumazet        2016-06-06  144  			seq = read_seqcount_begin(running);
22e0f8b9 John Fastabend      2014-09-28  145  		bstats->bytes = b->bytes;
22e0f8b9 John Fastabend      2014-09-28  146  		bstats->packets = b->packets;
edb09eb1 Eric Dumazet        2016-06-06  147  	} while (running && read_seqcount_retry(running, seq));
22e0f8b9 John Fastabend      2014-09-28  148  }
22e0f8b9 John Fastabend      2014-09-28  149  EXPORT_SYMBOL(__gnet_stats_copy_basic);
22e0f8b9 John Fastabend      2014-09-28  150  
^1da177e Linus Torvalds      2005-04-16  151  /**
^1da177e Linus Torvalds      2005-04-16  152   * gnet_stats_copy_basic - copy basic statistics into statistic TLV
^1da177e Linus Torvalds      2005-04-16  153   * @d: dumping handle
b002fdcc Luis de Bethencourt 2016-03-19  154   * @cpu: copy statistic per cpu
^1da177e Linus Torvalds      2005-04-16  155   * @b: basic statistics
^1da177e Linus Torvalds      2005-04-16  156   *
^1da177e Linus Torvalds      2005-04-16  157   * Appends the basic statistics to the top level TLV created by
^1da177e Linus Torvalds      2005-04-16  158   * gnet_stats_start_copy().
^1da177e Linus Torvalds      2005-04-16  159   *
^1da177e Linus Torvalds      2005-04-16  160   * Returns 0 on success or -1 with the statistic lock released
^1da177e Linus Torvalds      2005-04-16  161   * if the room in the socket buffer was not sufficient.
^1da177e Linus Torvalds      2005-04-16  162   */
^1da177e Linus Torvalds      2005-04-16  163  int
edb09eb1 Eric Dumazet        2016-06-06  164  gnet_stats_copy_basic(const seqcount_t *running,
edb09eb1 Eric Dumazet        2016-06-06  165  		      struct gnet_dump *d,
22e0f8b9 John Fastabend      2014-09-28  166  		      struct gnet_stats_basic_cpu __percpu *cpu,
22e0f8b9 John Fastabend      2014-09-28  167  		      struct gnet_stats_basic_packed *b)
^1da177e Linus Torvalds      2005-04-16 @168  {
22e0f8b9 John Fastabend      2014-09-28  169  	struct gnet_stats_basic_packed bstats = {0};
22e0f8b9 John Fastabend      2014-09-28  170  
edb09eb1 Eric Dumazet        2016-06-06  171  	__gnet_stats_copy_basic(running, &bstats, cpu, b);

:::::: The code at line 168 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--qMm9M+Fa2AknHoGS
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--qMm9M+Fa2AknHoGS--
