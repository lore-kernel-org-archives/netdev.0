From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 04 Oct 2012 17:42:25 -0400 (EDT)
Message-ID: <20121004.174225.33515477347980421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946317Ab2JDVm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 17:42:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The most important bit in here is the fix for input route caching
from Eric Dumazet, it's a shame we couldn't fully analyze this
in time for 3.6 as it's a 3.6 regression introduced by the routing
cache removal.

Anyways, will send quickly to -stable after you pull this in.

Other changes of note:

1) Fix lockdep splats in team and bonding, from Eric Dumazet.

2) IPV6 adds link local route even when there is no link local address,
   from Nicolas Dichtel.

3) Fix ixgbe PTP implementation, from Jacob Keller.

4) Fix excessive stack usage in cxgb4 driver, from Vipul Pandya.

5) MAC length computed improperly in VLAN demux, from Antonio
   Quartulli.

Please pull, thanks a lot!

The following changes since commit 7fe0b14b725d6d09a1d9e1409bd465cb88b587f9:

  Merge tag 'spi-3.7' of git://git.kernel.org/pub/scm/linux/kernel/git/broonie/misc (2012-10-02 17:26:42 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6825a26c2dc21eb4f8df9c06d3786ddec97cf53b:

  ipv6: release reference of ip6_null_entry's dst entry in __ip6_del_rt (2012-10-04 16:00:07 -0400)

----------------------------------------------------------------
Antonio Quartulli (1):
      8021q: fix mac_len recomputation in vlan_untag()

Dan Carpenter (1):
      bnx2x: use strlcpy() to copy a string

Dave Jones (2):
      silence some noisy printks in irda
      Remove noisy printks from llcp_sock_connect

David S. Miller (4):
      pch_gbe: Fix PTP dependencies.
      cxgb4: Fix build error due to missing linux/vmalloc.h include.
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'fixes-for-3.7' of git://gitorious.org/linux-can/linux-can

Emil Tantilov (1):
      ixgbe: fix poll loop for FDIRCTRL.INIT_DONE bit

Eric Dumazet (3):
      ipv4: add a fib_type to fib_info
      bonding: set qdisc_tx_busylock to avoid LOCKDEP splat
      team: set qdisc_tx_busylock to avoid LOCKDEP splat

Erik Hugne (1):
      tipc: prevent dropped connections due to rcvbuf overflow

Gao feng (1):
      ipv6: release reference of ip6_null_entry's dst entry in __ip6_del_rt

Jacob Keller (3):
      ixgbe: Fix PTP X540 SDP alignment code for PPS signal
      ixgbe: (PTP) Fix PPS interrupt code
      ixgbe: fix PTP ethtool timestamping function

Marc Kleine-Budde (1):
      can: mpc5xxx_can: fix section type conflict

Michael Chan (1):
      tg3: Fix sparse warnings.

Nicolas Dichtel (3):
      ipv6: don't add link local route when there is no link local address
      sctp: fix a typo in prototype of __sctp_rcv_lookup()
      sctp: check src addr when processing SACK to update transport state

Peter Senna Tschudin (2):
      can: peak_pci: fix error return code
      can: peak_pcmcia: fix error return code

Vipul Pandya (1):
      cxgb4: Dynamically allocate memory in t4_memory_rw() and get_vpd_params()

Yuval Mintz (1):
      bnx2x: fix ring size for 10G functions

htbegin (1):
      net: ethernet: davinci_cpdma: decrease the desc count when cleaning up the remaining packets

joshua.a.hay@intel.com (1):
      ixgbe: add support for X540-AT1

 drivers/net/bonding/bond_main.c                  |   2 +
 drivers/net/can/mscan/mpc5xxx_can.c              |   8 +--
 drivers/net/can/sja1000/peak_pci.c               |   2 +
 drivers/net/can/sja1000/peak_pcmcia.c            |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  17 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   5 +-
 drivers/net/ethernet/broadcom/tg3.c              |  11 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h       |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c       |  43 +++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  15 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     | 202 ++++++++++++++++++++++++++++++++++++----------------------------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   1 +
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig    |   2 +-
 drivers/net/ethernet/ti/davinci_cpdma.c          |   1 +
 drivers/net/team/team.c                          |   2 +
 include/net/ip_fib.h                             |   1 +
 include/net/sctp/structs.h                       |   2 +-
 net/8021q/vlan_core.c                            |   3 +-
 net/ipv4/fib_semantics.c                         |   2 +
 net/ipv6/addrconf.c                              |  15 +-----
 net/ipv6/route.c                                 |  11 +++--
 net/irda/af_irda.c                               |   2 +-
 net/irda/irttp.c                                 |   2 +-
 net/nfc/llcp/sock.c                              |   8 +--
 net/sctp/input.c                                 |   2 +-
 net/sctp/outqueue.c                              |  15 ++++--
 net/sctp/sm_sideeffect.c                         |   4 +-
 net/sctp/sm_statefuns.c                          |   2 +-
 net/tipc/socket.c                                |   1 +
 32 files changed, 209 insertions(+), 185 deletions(-)
