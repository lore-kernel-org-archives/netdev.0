From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 0/2] ipv4: Fix memory leaks and reference issues in fib
Date: Tue, 15 Nov 2016 05:46:01 -0500
Message-ID: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:6211 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751884AbcKOQrO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 11:47:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes one major issue and one minor issue in the fib tables.

The major issue is that we had lost the functionality that was flushing the
local table entries from main after we had unmerged the two tries.  In
order to regain the functionality I have performed a partial revert and
then moved the functionality for flushing the external entries from main
into fib_unmerge.

The minor issue was a memory leak that could occur in the event that we
weren't able to add an alias to the local trie resulting in the fib alias
being leaked.

---

Alexander Duyck (2):
      ipv4: Restore fib_trie_flush_external function and fix call ordering
      ipv4: Fix memory leak in exception case for splitting tries


 include/net/ip_fib.h    |    1 +
 net/ipv4/fib_frontend.c |   20 ++++++++++----
 net/ipv4/fib_trie.c     |   69 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 84 insertions(+), 6 deletions(-)
