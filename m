From: Antonio Quartulli <a@unstable.cc>
Subject: pull request: batman-adv 20160511
Date: Wed, 11 May 2016 03:29:48 +0800
Message-ID: <1462908605-27412-1-git-send-email-a__21427.6523016908$1462908672$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:17012 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbcEJTax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

here you have a pull request intended for net-next.
There are 17 patches in this batch, but most of them are cleanups
and minor code re-arrangement.

The more detailed description follows in the git tag.

Please pull or let me know of any problem.

Thanks a lot,
	Antonio


The following changes since commit c047c3b1af6214b447e353527e394fa3f3e86397:

  netfilter: conntrack: remove uninitialized shadow variable (2016-05-10 01:04:04 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 676970e55b1033af7f0a03d4037b4d9b76327ded:

  batman-adv: use batadv_compare_eth when possible (2016-05-10 18:28:54 +0800)

----------------------------------------------------------------
Included changes:
- remove useless skb size check in batadv_interface_rx
- basic netns support introduced by Andrew Lunn:
    - prevent virtual interface from changing netns by setting
      NETIF_F_NETNS_LOCAL
    - create virtual interface within the netns of the first
      hard-interface
- introduce detection of complex bridge loops and report event
  to the user (via udev) when the Bridge Loop Avoidance mechanism
  can't prevent them
- minor reference counting bugfixes for the hard_iface object that
  couldn't make it via the net tree
- use kref_get() instead of kref_get_unless_zero() to make reference
  counting bug more visible
- use batadv_compare_eth() all over the code when possible instead of
  plain memcmp()
- minor code cleanup and style adjustments

----------------------------------------------------------------
Andrew Lunn (2):
      batman-adv: NETIF_F_NETNS_LOCAL feature to prevent netns moves
      batman-adv: Create batman soft interfaces within correct netns.

Antonio Quartulli (1):
      batman-adv: use batadv_compare_eth when possible

Marek Lindner (1):
      batman-adv: replace ethertype variable with ETH_P_BATMAN for readability

Simon Wunderlich (1):
      batman-adv: add detection for complex bridge loops

Sven Eckelmann (12):
      batman-adv: Remove unused parameter recv_if of batadv_interface_rx
      batman-adv: Remove hdr_size skb size check in batadv_interface_rx
      batman-adv: Check hard_iface refcnt before calling function
      batman-adv: Check hard_iface refcnt when receiving skb
      batman-adv: Increase hard_iface refcnt for ptype
      batman-adv: Use kref_get for batadv_tvlv_container_get
      batman-adv: Use kref_get for batadv_nc_get_nc_node
      batman-adv: Use kref_get for batadv_gw_select
      batman-adv: Use kref_get for batadv_gw_node_add
      batman-adv: Use kref_get for hard_iface subfunctions
      batman-adv: Use kref_get for _batadv_update_route
      batman-adv: Use bool as return type for boolean functions

 net/batman-adv/bat_iv_ogm.c            |  48 ++---
 net/batman-adv/bat_v_ogm.c             |  14 +-
 net/batman-adv/bitarray.c              |  16 +-
 net/batman-adv/bitarray.h              |  15 +-
 net/batman-adv/bridge_loop_avoidance.c | 314 ++++++++++++++++++++++++---------
 net/batman-adv/bridge_loop_avoidance.h |  43 ++---
 net/batman-adv/debugfs.c               |   2 +-
 net/batman-adv/distributed-arp-table.c |   6 +-
 net/batman-adv/gateway_client.c        |  12 +-
 net/batman-adv/hard-interface.c        |  34 ++--
 net/batman-adv/hard-interface.h        |   3 +-
 net/batman-adv/hash.h                  |   6 +-
 net/batman-adv/main.c                  |  18 +-
 net/batman-adv/main.h                  |   6 +-
 net/batman-adv/network-coding.c        |  25 +--
 net/batman-adv/originator.c            |  39 ++--
 net/batman-adv/originator.h            |   2 +-
 net/batman-adv/packet.h                |   1 +
 net/batman-adv/routing.c               |  50 +++---
 net/batman-adv/routing.h               |   6 +-
 net/batman-adv/send.c                  |   6 +
 net/batman-adv/soft-interface.c        |  32 ++--
 net/batman-adv/soft-interface.h        |  10 +-
 net/batman-adv/sysfs.c                 |   9 +-
 net/batman-adv/translation-table.c     |  35 ++--
 net/batman-adv/types.h                 |   8 +
 26 files changed, 465 insertions(+), 295 deletions(-)
