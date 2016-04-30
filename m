From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net]: batman-adv 20160430
Date: Sun,  1 May 2016 01:05:59 +0800
Message-ID: <1462035963-28970-1-git-send-email-a__35069.0967323773$1462036012$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:35121 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbcD3RGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2016 13:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is another pull request intended for net.

I know that I sent another batch a few days ago, but after having gone
through my queue I thought that merging these last 4 patches would still
be worth it (there won't be any other pull request for linux-4.6 :)).

The description of the changes follows below.

Please pull or let me know of any issue!
Thanks a lot,
	Antonio

The following changes since commit 1dfcd832b1a9ed45edac15b31d079b805fa0ae2a:

  Merge branch 'bpf-fixes' (2016-04-28 17:29:46 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to abe59c65225ccd63a5964e2f2a73dd2995b948e7:

  batman-adv: Fix reference counting of hardif_neigh_node object for neigh_node (2016-04-29 19:46:11 +0800)

----------------------------------------------------------------
In this small batch of patches you have:
- a fix for our Distributed ARP Table that makes sure that the input
  provided to the hash function during a query is the same as the one
  provided during an insert (so to prevent false negatives), by Antonio
  Quartulli
- a fix for our new protocol implementation B.A.T.M.A.N. V that ensures
  that a hard interface is properly re-activated when it is brought down
  and then up again, by Antonio Quartulli
- two fixes respectively to the reference counting of the tt_local_entry
  and neigh_node objects, by Sven Eckelmann. Such bug is rather severe
  as it would prevent the netdev objects references by batman-adv from
  being released after shutdown.

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: fix DAT candidate selection (must use vid)
      batman-adv: B.A.T.M.A.N V - make sure iface is reactivated upon NETDEV_UP event

Sven Eckelmann (2):
      batman-adv: Fix reference counting of vlan object for tt_local_entry
      batman-adv: Fix reference counting of hardif_neigh_node object for neigh_node

 net/batman-adv/bat_v.c                 | 12 ++++++++++
 net/batman-adv/distributed-arp-table.c | 17 ++++++++------
 net/batman-adv/hard-interface.c        |  3 +++
 net/batman-adv/originator.c            | 16 ++++---------
 net/batman-adv/translation-table.c     | 42 ++++------------------------------
 net/batman-adv/types.h                 |  7 ++++++
 6 files changed, 41 insertions(+), 56 deletions(-)
