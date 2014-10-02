From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 01 Oct 2014 23:03:55 -0400 (EDT)
Message-ID: <20141001.230355.701078479082003407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaJBDD7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 23:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Don't halt the firmware in r8152 driver, from Hayes Wang.

2) Handle full sized 802.1ad frames in bnx2 and tg3 drivers
   properly, from Vlad Yasevich.

3) Don't sleep while holding tx_clean_lock in netxen driver,
   fix from Manish Chopra.

4) Certain kinds of ipv6 routes can end up endlessly failing
   the route validation test, causing it to be re-looked up
   over and over again.  This particularly kills input route
   caching in TCP sockets.  Fix from Hannes Frederic Sowa.

5) netvsc_start_xmit() has a use-after-free access to skb->len,
   fix from K. Y. Srinivasan.

6) Fix matching of inverted containers in ematch module, from
   Ignacy Gaw=EAdzki.

7) Aggregation of GRO frames via SKB ->frag_list for linear skbs isn't
   handled properly, regression fix from Eric Dumazet.

8) Don't test return value of ipv4_neigh_lookup(), which returns an
   error pointer, against NULL.  From WANG Cong.

9) Fix an old regression where we mistakenly allow a double add
   of the same tunnel.  Fixes from Steffen Klassert.

10) macvtap device delete and open can run in parallel and corrupt
    lists etc., fix from Vlad Yasevich.

11) Fix build error with IPV6=3Dm NETFILTER_XT_TARGET_TPROXY=3Dy, from
    Pablo Neira Ayuso.

12) rhashtable_destroy() triggers lockdep splats, fix also from
    Pablo.

Please pull, thanks a lot!

The following changes since commit b94d525e58dc9638dd3f98094cb468bcfb26=
2039:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-0=
9-24 12:45:24 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 439e9575e777bdad1d9da15941e02adf34f4c392=
:

  bna: Update Maintainer Email (2014-10-01 22:13:41 -0400)

----------------------------------------------------------------
David S. Miller (5):
      Merge branch 'qlcnic'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'ipv6_tunnel'
      Merge branch 'netxen'
      Merge branch 'r8152'

Eric Dumazet (1):
      gro: fix aggregation for skb using frag_list

Hannes Frederic Sowa (1):
      ipv6: remove rt6i_genid

Ignacy Gaw=EAdzki (1):
      ematch: Fix matching of inverted containers.

KY Srinivasan (1):
      hyperv: Fix a bug in netvsc_start_xmit()

Kweh, Hock Leong (1):
      net: stmmac: fix stmmac_pci_probe failed when CONFIG_HAVE_CLK is =
selected

Manish Chopra (5):
      qlcnic: Fix memory corruption while reading stats using ethtool.
      qlcnic: Remove __QLCNIC_DEV_UP bit check to read TX queues statis=
tics.
      qlcnic: Fix ordering of stats in stats buffer.
      netxen: Fix BUG "sleeping function called from invalid context"
      netxen: Fix bug in Tx completion path.

Matan Barak (1):
      net/mlx4_core: Allow not to specify probe_vf in SRIOV IB mode

Nicolas Dichtel (1):
      ip6gre: add a rtnl link alias for ip6gretap

Pablo Neira Ayuso (5):
      netfilter: nft_hash: no need for rcu in the hash set destroy path
      netfilter: nft_rbtree: no need for spinlock from set destroy path
      rhashtable: fix lockdep splat in rhashtable_destroy()
      netfilter: nfnetlink: deliver netlink errors on batch completion
      netfilter: xt_TPROXY: undefined reference to `udp6_lib_lookup'

Rasesh Mody (1):
      bna: Update Maintainer Email

Sony Chacko (1):
      qlcnic: Use qlcnic_83xx_flash_read32() API instead of lockless ve=
rsion of the API.

Soren Brinkmann (1):
      Revert "net/macb: add pinctrl consumer support"

Steffen Klassert (4):
      ip_tunnel: Don't allow to add the same tunnel multiple times.
      ip6_tunnel: Return an error when adding an existing tunnel.
      ip6_vti: Return an error when adding an existing tunnel.
      ip6_gre: Return an error when adding an existing tunnel.

Vlad Yasevich (3):
      macvtap: Fix race between device delete and open.
      tg3: Allow for recieve of full-size 8021AD frames
      bnx2: Correctly receive full sized 802.1ad fragmes

WANG Cong (1):
      neigh: check error pointer instead of NULL for ipv4_neigh_lookup(=
)

hayeswang (4):
      r8152: fix the carrier off when autoresuming
      r8152: fix setting RTL8152_UNPLUG
      r8152: remove clearing bp
      r8152: disable power cut for RTL8153

 MAINTAINERS                                           |  2 +-
 drivers/net/ethernet/broadcom/bnx2.c                  |  5 ++--
 drivers/net/ethernet/broadcom/tg3.c                   |  3 +-
 drivers/net/ethernet/cadence/macb.c                   | 11 -------
 drivers/net/ethernet/mellanox/mlx4/main.c             |  4 +--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c  |  6 ++--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c  |  2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |  5 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c   | 10 +++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 11 +++++--
 drivers/net/hyperv/netvsc_drv.c                       |  3 +-
 drivers/net/macvtap.c                                 | 18 +++++------
 drivers/net/usb/r8152.c                               | 88 +++++++++++=
+++++++++++++++----------------------------
 include/net/ip6_fib.h                                 |  5 +---
 include/net/net_namespace.h                           | 20 ++---------=
--
 lib/rhashtable.c                                      |  8 ++---
 net/core/skbuff.c                                     |  3 ++
 net/ipv4/ip_tunnel.c                                  | 11 +++++--
 net/ipv4/route.c                                      |  2 +-
 net/ipv6/addrconf.c                                   |  3 +-
 net/ipv6/addrconf_core.c                              |  7 +++++
 net/ipv6/ip6_fib.c                                    | 20 +++++++++++=
++
 net/ipv6/ip6_gre.c                                    |  3 ++
 net/ipv6/ip6_tunnel.c                                 |  6 +++-
 net/ipv6/ip6_vti.c                                    |  6 +++-
 net/ipv6/route.c                                      |  4 ---
 net/netfilter/Kconfig                                 |  1 +
 net/netfilter/nfnetlink.c                             | 64 +++++++++++=
+++++++++++++++++++++++++++-
 net/netfilter/nft_hash.c                              | 12 ++++----
 net/netfilter/nft_rbtree.c                            |  2 --
 net/sched/ematch.c                                    |  6 ++--
 31 files changed, 217 insertions(+), 134 deletions(-)
