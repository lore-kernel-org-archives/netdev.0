From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 07 Mar 2012 00:22:11 -0500 (EST)
Message-ID: <20120307.002211.1109938489960237946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) TCP can chop up SACK'd SKBs below below the unacked send
   sequence and that breaks lots of stuff.  Fix from Neal Cardwell.

2) There is code in ipv6 to properly join and leave the all-routers
   multicast code when the forwarding setting is changed, but once
   forwarding is turned on, we don't do the join for newly registered
   devices.  Fix from Li Wei.

3) Netfilter's NAT module autoload in ctnetlink drops a spinlock around
   a sleeping call, problem is this code path doesn't actually hold tha=
t
   lock.  Fix from Pablo Neira Ayuso.

4) TG3 uses the wrong interfaces to hook into the new byte queue limit
   support.  It uses the device level interfaces, which is fine for
   single queue devices, but on more recent chips this driver supports
   multiqueue so we have to use the multiqueue BQL APIs.  Fix from Tom
   Herbert.

5) r8169 resume fix from Francois Romieu.

6) Add some cxgb4 device IDs, from Vipul Pandya.

Please pull, thanks a lot!

The following changes since commit 55062d061790b43aee01ab3f9ac57b859625=
4f19:

  x86: fix typo in recent find_vma_prev purge (2012-03-06 18:48:13 -080=
0)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

=46lorian Westphal (1):
      bridge: netfilter: don't call iptables on vlan packets if sysctl =
is off

Li Wei (1):
      IPv6: Fix not join all-router mcast group when forwarding set.

Neal Cardwell (1):
      tcp: fix tcp_shift_skb_data() to not shift SACKed data below snd_=
una

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: remove incorrect spin_[un]lock_bh on NAT mo=
dule autoload
      netfilter: bridge: fix wrong pointer dereference
      netfilter: nf_conntrack: fix early_drop with reliable event deliv=
ery

Santosh Nayak (1):
      netfilter: ebtables: fix wrong name length while copying to user-=
space

Sjur Br=E6ndeland (1):
      caif-hsi: Set default MTU to 4096

Tom Herbert (1):
      tg3: Fix to use multi queue BQL interfaces

Vipul Pandya (2):
      cxgb4: Add support for Chelsio's T480-CR and T440-LP-CR adapters
      cxgb4vf: Add support for Chelsio's T480-CR and T440-LP-CR adapter=
s

Yevgeny Petrilin (1):
      mlx4_core: remove buggy sched_queue masking

fran=E7ois romieu (1):
      r8169: runtime resume before shutdown.

 drivers/net/caif/caif_hsi.c                        |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    6 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 ---
 drivers/net/ethernet/realtek/r8169.c               |    5 +++
 net/bridge/br_netfilter.c                          |   32 +++++++++++-=
-------
 net/bridge/netfilter/ebtables.c                    |   16 ++++++++--
 net/ipv4/tcp_input.c                               |    4 ++
 net/ipv6/addrconf.c                                |    4 ++
 net/netfilter/nf_conntrack_core.c                  |    8 ++++-
 net/netfilter/nf_conntrack_netlink.c               |    3 --
 12 files changed, 58 insertions(+), 31 deletions(-)
