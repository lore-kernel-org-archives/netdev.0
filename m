From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 02 Nov 2012 23:46:51 -0400 (EDT)
Message-ID: <20121102.234651.536037174791637359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab2KCDqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 23:46:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First post-Sandy pull request, here goes:

1) Fix antenna gain handling and initialization of chan->max_reg_power
   in wireless, from Felix Fietkau.

2) Fix nexthop handling in H.232 conntrack helper, from Julian
   Anastasov.

3) Only process 80211 mesh config header in certain kinds of frames,
   from Javier Cardona.

4) 80211 management frame header length needs to be validated, from
   Johannes Berg.

5) Don't access free'd SKBs in ath9k driver, from Felix Fietkay.

6) Test for permanent state correctly in VXLAN driver, from Stephen
   Hemminger.

7) BNX2X bug fixes from Yaniv Rosner and Dmitry Kravkov.

8) Fix off by one errors in bonding, from Nikolay ALeksandrov.

9) Fix divide by zero in TCP-Illinois congestion control.  From
   Jesper Dangaard Brouer.

10) TCP metrics code says "Yo dawg, I heard you like sizeof, so I
    did a sizeof of a sizeof, so you can size your size" Fix from
    Julian Anastasov.

11) Several drivers do mdiobus_free without first doing an
    mdiobus_unregister leading to stray pointer references.
    Fix from Peter Senna Tschudin.

12) Fix OOPS in l2tp_eth_create() error path, it's another danling
    pointer kinda situation.  Fix from Tom Parkin.

13) Hardware driven by the vmxnet driver can't handle larger than 16K
    fragments, so split them up when necessary.  From Eric Dumazet.

14) Handle zero length data length in tcp_send_rcvq() properly.  Fix
    from Pavel Emelyanov.

Please pull, thanks a lot!

The following changes since commit e657e078d3dfa9f96976db7a2b5fd7d7c9f1f1a6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-10-26 15:00:48 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to c454e6111d1ef4268fe98e87087216e51c2718c3:

  tcp-repair: Handle zero-length data put in rcv queue (2012-11-02 22:01:45 -0400)

----------------------------------------------------------------
Antonio Quartulli (1):
      mac80211: fix SSID copy on IBSS JOIN

David S. Miller (2):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Dmitry Kravkov (2):
      bnx2x: Disable FCoE for 57840 since not yet supported by FW
      bnx2x: fix HW initialization using fw 7.8.x

Eric Dumazet (1):
      vmxnet3: must split too big fragments

Felix Fietkau (3):
      cfg80211: fix antenna gain handling
      cfg80211: fix initialization of chan->max_reg_power
      ath9k: fix stale pointers potentially causing access to free'd skbs

Hein Tibosch (1):
      netfilter: nf_defrag_ipv6: solve section mismatch in nf_conntrack_reasm

Jacob Keller (1):
      ixgbe: PTP get_ts_info missing software support

Javier Cardona (3):
      mac80211: Only process mesh config header on frames that RA_MATCH
      mac80211: Don't drop frames received with mesh ttl == 1
      mac80211: don't inspect Sequence Control field on control frames

Jesper Dangaard Brouer (1):
      net: fix divide by zero in tcp algorithm illinois

Johannes Berg (5):
      mac80211: use blacklist for duplicate IE check
      wireless: drop invalid mesh address extension frames
      mac80211: check management frame header length
      mac80211: verify that skb data is present
      mac80211: make sure data is accessible in EAPOL check

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julian Anastasov (2):
      netfilter: nf_conntrack: fix rt_gateway checks for H.323 helper
      tcp: Fix double sizeof in new tcp_metrics code

Masanari Iida (1):
      net: sctp: Fix typo in net/sctp

Pavel Emelyanov (1):
      tcp-repair: Handle zero-length data put in rcv queue

Peter Senna Tschudin (2):
      drivers/net/ethernet/nxp/lpc_eth.c: Call mdiobus_unregister before mdiobus_free
      drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregister before mdiobus_free

Stanislaw Gruszka (1):
      rt2800: validate step value for temperature compensation

Sven Eckelmann (1):
      ath9k: Test for TID only in BlockAcks while checking tx status

Tom Parkin (1):
      l2tp: fix oops in l2tp_eth_create() error path

Ulrich Weber (1):
      netfilter: nf_nat: don't check for port change on ICMP tuples

Vipul Pandya (1):
      cxgb4: Fix unable to get UP event from the LLD

Yaniv Rosner (6):
      bnx2x: Fix 57810 1G-KR link against certain switches.
      bnx2x: Fix link down in 57712 following LFA
      bnx2x: Restore global registers back to default.
      bnx2x: Fix potential incorrect link speed provision
      bnx2x: Fix unrecognized SFP+ module after driver is loaded
      bnx2x: Fix no link on 577xx 10G-baseT

nikolay@redhat.com (2):
      bonding: fix off-by-one error
      bonding: fix second off-by-one error

stephen hemminger (1):
      vxlan: don't expire permanent entries

 drivers/net/bonding/bond_sysfs.c                 |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 158 +++++++++++++++++++++++++++++++++++--------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  13 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c  |  10 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   3 +
 drivers/net/ethernet/nxp/lpc_eth.c               |   1 +
 drivers/net/phy/mdio-bitbang.c                   |   1 +
 drivers/net/vmxnet3/vmxnet3_drv.c                |  65 +++++++++++++-------
 drivers/net/vxlan.c                              |   2 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |  10 +++-
 drivers/net/wireless/rt2x00/rt2800lib.c          |   2 +-
 include/net/cfg80211.h                           |   9 +++
 net/ipv4/netfilter/iptable_nat.c                 |   4 +-
 net/ipv4/tcp_illinois.c                          |   8 ++-
 net/ipv4/tcp_input.c                             |   3 +
 net/ipv4/tcp_metrics.c                           |   2 +-
 net/ipv6/netfilter/ip6table_nat.c                |   4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c          |   4 +-
 net/l2tp/l2tp_eth.c                              |   1 +
 net/mac80211/ibss.c                              |   2 +-
 net/mac80211/rx.c                                |  74 +++++++++++++++++------
 net/mac80211/util.c                              |  42 ++++++++++---
 net/netfilter/nf_conntrack_h323_main.c           |   3 +-
 net/sctp/socket.c                                |   2 +-
 net/wireless/core.c                              |   3 +-
 net/wireless/reg.c                               |   5 +-
 net/wireless/util.c                              |  14 +++--
 27 files changed, 320 insertions(+), 129 deletions(-)
