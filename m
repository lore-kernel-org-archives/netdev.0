From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [IPV4 0/9] TRIE performance patches
Date: Fri, 1 Feb 2008 19:00:55 +0100
Message-ID: <18339.24151.771674.992957@robur.slu.se>
References: <20080122233733.404145234@linux-foundation.org>
	<18327.18935.137799.285515@robur.slu.se>
	<20080123154933.233c4909@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:51633 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227AbYBASBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:01:04 -0500
In-Reply-To: <20080123154933.233c4909@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello, finally got some time to test...

Table w. 214k routes with full rDoS on two intrefaces on 2 x AMD64 processors, 
speed 2814.43 MHz. Profiled with CPU_CLK_UNHALTED and rtstat

w/o latest patch fib_trie pathes. Tput ~233 kpps  

samples  %        symbol name

109925   14.4513  fn_trie_lookup
109821   14.4376  ip_route_input
87245    11.4696  rt_intern_hash
31270     4.1109  kmem_cache_alloc
24159     3.1761  dev_queue_xmit
23200     3.0500  neigh_lookup
22464     2.9532  free_block
18412     2.4205  kmem_cache_free
17830     2.3440  dst_destroy
15740     2.0693  fib_get_table

With latest patch fib_patches.(Stephens others) Same throughput 
~233 kpps but we see a different profile. Why we don't get any 
better better throughput is yet to be understand (the drops in 
qdisc could be the cause) more analysis needed

79242    14.3520  ip_route_input
65188    11.8066  fn_trie_lookup
64559    11.6927  rt_intern_hash
22901     4.1477  kmem_cache_alloc
21038     3.8103  check_leaf
16197     2.9335  neigh_lookup
14802     2.6809  free_block
14596     2.6436  ip_rcv_finish
12365     2.2395  fib_validate_source
12048     2.1821  dst_destroy

fib_hash thoughput ~177 kpps  
Hard work for fib_hash here as we have many zones.
it can be fast with less zines.

200568   37.8013  fn_hash_lookup
58352    10.9977  ip_route_input
44495     8.3860  rt_intern_hash
12873     2.4262  kmem_cache_alloc
12115     2.2833  rt_may_expire
11691     2.2034  rt_garbage_collect
10821     2.0394  dev_queue_xmit
9999      1.8845  fib_validate_source
8762      1.6514  fib_get_table
8558      1.6129  fib_semantic_match


Cheers
					--ro
