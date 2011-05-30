From: Sven Eckelmann <sven@narfation.org>
Subject: batman-adv 2011-05-30
Date: Mon, 30 May 2011 09:22:45 +0200
Message-ID: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60250 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755054Ab1E3HXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to propose following patches for net-next-2.6/3.1 [1]. It
is not really based on your net-next-2.6 tree, but directly on v3.0-rc1.
I hope that this is ok - thought that you will merge that version
anyway. Just wanted to get these patches out before doing the really
work (reducing the amount of patches you get in a single pull request).

Most patches are only cleanup patches - nothing really interesting.
Antonio also moved the protocol specific seq_before/seq_after function
to main.h like you told us [2]. Now he can use it in his translation
table query patches (they are still moving, so he needs to hunt them
down before I can submit them).

thanks,
	Sven

[1] wow, that sounds creepy
[2] https://lkml.org/lkml/2011/5/19/88


The following changes since commit 55922c9d1b84b89cb946c777fddccb3247e7df2c:

  Linux 3.0-rc1 (2011-05-29 17:43:36 -0700)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Antonio Quartulli (4):
      batman-adv: move neigh_node->if_incoming->if_status check in find_router()
      batman-adv: move smallest_signed_int(), seq_before() and seq_after() into main.h
      batman-adv: use is_broadcast_ether_addr() instead of compare_eth(.., brd_addr)
      batman-adv: a multiline comment should precede the variable it is describing

Sven Eckelmann (13):
      batman-adv: Use kzalloc rather than kmalloc followed by memset with 0
      batman-adv: Annotate functions with format strings
      batman-adv: Print jiffies as unsigned long
      batman-adv: Remove comparising < 0 for unsigned type
      batman-adv: Don't do pointer arithmetic with void*
      batman-adv: Add const type qualifier for pointers
      batman-adv: Only use int up and down gw representation
      batman-adv: Remove explicit casts cast from void* for store
      batman-adv: Remove casts from type x to type x
      batman-adv: Calculate sizeof using variable insead of types
      batman-adv: Use rcu_dereference_protected by update-side
      batman-adv: Check type of x and y in seq_(before|after)
      batman-adv: Ensure that we really have route changes in update_route

 net/batman-adv/aggregation.c       |   23 +++++----
 net/batman-adv/aggregation.h       |    5 +-
 net/batman-adv/bat_debugfs.c       |   11 ++--
 net/batman-adv/bat_sysfs.c         |   15 +++---
 net/batman-adv/bitarray.c          |    6 +-
 net/batman-adv/bitarray.h          |    6 +-
 net/batman-adv/gateway_client.c    |   19 ++++----
 net/batman-adv/gateway_common.c    |   19 ++++----
 net/batman-adv/hard-interface.c    |   25 +++++-----
 net/batman-adv/hard-interface.h    |    6 ++-
 net/batman-adv/hash.c              |    7 ++-
 net/batman-adv/hash.h              |    6 +-
 net/batman-adv/icmp_socket.c       |    4 +-
 net/batman-adv/main.c              |    4 +-
 net/batman-adv/main.h              |   30 ++++++++++--
 net/batman-adv/originator.c        |   12 ++--
 net/batman-adv/originator.h        |   14 +++---
 net/batman-adv/ring_buffer.c       |    4 +-
 net/batman-adv/ring_buffer.h       |    2 +-
 net/batman-adv/routing.c           |   54 +++++++++++-----------
 net/batman-adv/routing.h           |   12 ++--
 net/batman-adv/send.c              |   44 +++++++++---------
 net/batman-adv/send.h              |   12 ++--
 net/batman-adv/soft-interface.c    |   22 ++++-----
 net/batman-adv/soft-interface.h    |    4 +-
 net/batman-adv/translation-table.c |   44 +++++++++--------
 net/batman-adv/translation-table.h |   13 +++--
 net/batman-adv/types.h             |    8 ++--
 net/batman-adv/unicast.c           |   30 +++++-------
 net/batman-adv/unicast.h           |    8 ++--
 net/batman-adv/vis.c               |   91 +++++++++++++++---------------------
 31 files changed, 284 insertions(+), 276 deletions(-)
