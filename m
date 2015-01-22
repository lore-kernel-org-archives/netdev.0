From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [next-next PATCH 0/7] Fixes and improvements for recent fib_trie
 updates
Date: Thu, 22 Jan 2015 15:51:01 -0800
Message-ID: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbbAVXvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:51:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While performing testing and prepping the next round of patches I found a
few minor issues and improvements that could be made.

These changes should help to reduce the overall code size and improve the
performance slighlty as I noticed a 20ns or so improvement in my worst-case
testing which will likely only result in a 1ns difference with a standard
sized trie.

---

Alexander Duyck (7):
      fib_trie: Use index & (~0ul << n->bits) instead of index >> n->bits
      fib_trie: Fix RCU bug and merge similar bits of inflate/halve
      fib_trie: Fall back to slen update on inflate/halve failure
      fib_trie: Add collapse() and should_collapse() to resize
      fib_trie: Use empty_children instead of counting empty nodes in stats collection
      fib_trie: Move fib_find_alias to file where it is used
      fib_trie: Various clean-ups for handling slen


 net/ipv4/fib_lookup.h    |    1 
 net/ipv4/fib_semantics.c |   18 --
 net/ipv4/fib_trie.c      |  354 ++++++++++++++++++++++++++--------------------
 3 files changed, 198 insertions(+), 175 deletions(-)

--
