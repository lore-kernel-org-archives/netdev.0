From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v2 0/2] ipv6: prevent fib6_run_gc() contention
Date: Thu,  1 Aug 2013 10:04:04 +0200 (CEST)
Message-ID: <cover.1375343204.git.mkubecek@suse.cz>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42436 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479Ab3HAIEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 04:04:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a high-traffic router with many processors and many IPv6 dst entries,
soft lockup in fib6_run_gc() can occur when number of entries reaches
gc_thresh. Prevent this by not waiting for the lock if garbage collector
is already running as we would only run it again as soon as it finished.

v2: as suggested by Eric Dumazet, move update of ip6_rt_last_gc into
    fib6_run_gc() so that it reflects every run of garbage collector
    rather than only those via ip6_dst_gc()

Michal Kubecek (2):
  ipv6: prevent fib6_run_gc() contention
  ipv6: update ip6_rt_last_gc every time GC is run

 include/net/ip6_fib.h |  2 +-
 net/ipv6/ip6_fib.c    | 25 +++++++++++++------------
 net/ipv6/ndisc.c      |  4 ++--
 net/ipv6/route.c      |  8 +++-----
 4 files changed, 19 insertions(+), 20 deletions(-)

-- 
1.8.1.4
