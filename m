From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH RFC net-next 0/2] Fix pfmemalloc in __netdev_alloc_skb
Date: Sun, 24 Aug 2014 03:07:17 +0530
Message-ID: <1408829839-20742-1-git-send-email-_govind@gmx.com>
Cc: davem@davemloft.net, edumazet@google.com, mgorman@suse.de,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:50129 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbaHWVhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2014 17:37:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

After the introduction of skb->pfmemalloc in
c93bdd0e0:(allow skb allocation to use PFMEMALLOC reserves), skb->pfmemalloc
should be set to true if buff is allocated from reserve memory.

But in a1c7fff7e(netdev_alloc_skb() use build_skb()), netdev_alloc_skb() does
not set skb->pfmemalloc if the page is allocated from reserve memory.

Also if the page in netdev_alloc_cache->frag is allocated from reserve memory,
and if the next call to __netdev_alloc_frag does not have __GFP_MEMALLOC in
flags, we should not return a reserved memory. Because the reserve memory could
be sitting in receive queue waiting for packet to arrive. We should release
the reserve memory as soon as possible.

Is my understanding correct?

Govindarajulu Varadarajan (2):
  net: skbuff: propagate pfmemalloc to skb
  net: skbuff: do not allocate emergency memory if flags is not
    __GFP_MEMALLOC

 net/core/skbuff.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

-- 
2.1.0
