From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/5 net-next] rhashtable updates on top of Herbert's work
Date: Tue, 24 Mar 2015 14:18:15 +0100
Message-ID: <cover.1427202823.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34627 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbbCXNSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:18:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 is a bugfix for an RCU splash I encountered while testing.
Patch 2 & 3 are pure cleanups. Patch 4 disables automatic shrinking
by default as discussed in previous thread. Patch 5 removes some
rhashtable internal knowledge from nft_hash and fixes another RCU
splash.

I've pushed various rhashtable tests (Netlink, nft) together with a
Makefile to a git tree [0] for easier stress testing.

[0] https://github.com/tgraf/rhashtable

Thomas Graf (5):
  rhashtable: Extend RCU read lock into rhashtable_insert_rehash()
  rhashtable: Use 'unsigned int' consistently
  rhashtable: Mark internal/private inline functions as such
  rhashtable: Disable automatic shrinking by default
  rhashtable: Add rhashtable_free_and_destroy()

 include/linux/rhashtable.h | 50 +++++++++++++++++++++++-----------
 lib/rhashtable.c           | 67 +++++++++++++++++++++++++++++++++-------------
 lib/test_rhashtable.c      |  2 +-
 net/netfilter/nft_hash.c   | 27 ++++++-------------
 net/netlink/af_netlink.c   |  4 +--
 net/tipc/socket.c          |  3 ++-
 6 files changed, 96 insertions(+), 57 deletions(-)

-- 
1.9.3
