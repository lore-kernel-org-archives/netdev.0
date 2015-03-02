From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/6] ipv4/fib_trie: Cleanups to prepare for
 introduction of key vector
Date: Mon, 02 Mar 2015 13:32:16 -0800
Message-ID: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbbCBVcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 16:32:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to mostly just clean up the fib_trie to prepare
it for the introduction of the key_vector.  As such there are a number of
minor clean-ups such as reformatting the tnode to match the format once the
key vector is introduced, some optimizations to drop the need for a leaf
parent pointer, and some changes to remove duplication of effort such as
the 2 look-ups that were essentially being done per node insertion.

---

Alexander Duyck (6):
      fib_trie: Only resize tnodes once instead of on each leaf removal in fib_table_flush
      fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf
      fib_trie: Fib find node should return parent
      fib_trie: Update insert and delete to make use of tp from find_node
      fib_trie: move leaf and tnode to occupy the same spot in the key vector
      fib_trie: Make fib_table rcu safe


 include/net/ip_fib.h     |   70 +++--
 include/net/netns/ipv4.h |    7 -
 net/ipv4/fib_frontend.c  |   52 +++-
 net/ipv4/fib_trie.c      |  628 +++++++++++++++++++++++-----------------------
 4 files changed, 399 insertions(+), 358 deletions(-)

--
