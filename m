From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 0/8] ipv4/fib_trie: Cleanups to prepare for
 introduction of key vector
Date: Wed, 04 Mar 2015 14:57:55 -0800
Message-ID: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121AbbCDW55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 17:57:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to mostly just clean up the fib_trie to prepare
it for the introduction of the key_vector.  As such there are a number of
minor clean-ups such as reformatting the tnode to match the format once the
key vector is introduced, some optimizations to drop the need for a leaf
parent pointer, and some changes to remove duplication of effort such as
the 2 look-ups that were essentially being done per node insertion.

v2: Added code to cleanup idx >> n->bits and explain unsigned long logic
    Added code to prevent allocation when tnode size is larger than size_t

---

Alexander Duyck (8):
      fib_trie: Only resize tnodes once instead of on each leaf removal in fib_table_flush
      fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf
      fib_trie: Fib find node should return parent
      fib_trie: Update insert and delete to make use of tp from find_node
      fib_trie: move leaf and tnode to occupy the same spot in the key vector
      fib_trie: Make fib_table rcu safe
      fib_trie: Update last spot w/ idx >> n->bits code and explanation
      fib_trie: Prevent allocating tnode if bits is too big for size_t


 include/net/ip_fib.h     |   70 +++--
 include/net/netns/ipv4.h |    7 
 net/ipv4/fib_frontend.c  |   52 +++-
 net/ipv4/fib_trie.c      |  672 ++++++++++++++++++++++++----------------------
 4 files changed, 433 insertions(+), 368 deletions(-)

--
