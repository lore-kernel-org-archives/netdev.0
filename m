From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net]: batman-adv 20160114
Date: Thu, 14 Jan 2016 01:51:52 +0800
Message-ID: <1452707514-5091-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:33042 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932349AbcAMRxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 12:53:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

these are two small fixes intended for your net tree.

Patch 1 prevents a lockdep splat from appearing along the
shutdown path due to a missing lock in mcast_free(), by Simon Wunderlich.

Patch 2 fixes a new feature introduced in 4.5 by ensuring that a
batadv_hardif_neigh_node object is free'd only when it is no
longer used in any context, by Sven Eckelmann.

Please pull or let me know of any issue.
Thanks a lot,
	Antonio

The following changes since commit f1640c3ddeec12804bc9a21feee85fc15aca95f6:

  bgmac: fix a missing check for build_skb (2016-01-13 00:24:14 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to bab7c6c3deac70966a3000402c0ea6d0c20edd15:

  batman-adv: Fix list removal of batadv_hardif_neigh_node (2016-01-13 19:28:27 +0800)

----------------------------------------------------------------
Included bugfixes:
- avoid freeing batadv_hardif_neigh_node when still in use in other contexts
- prevent lockdep splat in mcast_free during shutdown

----------------------------------------------------------------
Simon Wunderlich (1):
      batman-adv: fix lockdep splat when doing mcast_free

Sven Eckelmann (1):
      batman-adv: Fix list removal of batadv_hardif_neigh_node

 net/batman-adv/multicast.c  |  2 ++
 net/batman-adv/originator.c | 18 ++++++++++++------
 2 files changed, 14 insertions(+), 6 deletions(-)
