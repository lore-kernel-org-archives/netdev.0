From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 27 Jan 2015 12:36:20 -0800 (PST)
Message-ID: <20150127.123620.1397035458019295241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't OOPS on socket AIO, from Christoph Hellwig.

2) Scheduled scans should be aborted upon RFKILL, from Emmanuel Grumbach.

3) Fix sleep in atomic context in kvaser_usb, from Ahmed S. Darwish.

4) Fix RCU locking across copy_to_user() in bpf code, from Alexei
   Starovoitov.

5) Lots of crash, memory leak, short TX packet et al. bug fixes in sh_eth
   from Ben Hutchings.

6) Fix memory corruption in SCTP wrt. INIT collitions, from Daniel
   Borkmann.

7) Fix return value logic for poll handlers in netxen, enic, and
   bnx2x.  From Eric Dumazet and Govindarajulu Varadarajan.

8) Header length calculation fix in mac80211 from Fred Chou.

9) mv643xx_eth doesn't handle highmem correctly in non-TSO code
   paths.  From Ezequiel Garcia.

10) udp_diag has bogus logic in it's hash chain skipping, copy
    same fix tcp diag used.  From Herbert Xu.

11) amd-xgbe programs wrong rx flow control register, from Thomas
    Lendacky.

12) Fix race leading to use after free in ping receive path,
    from Subash Abhinov Kasiviswanathan.

13) Cache redirect routes otherwise we can get a heavy backlog
    of rcu jobs liberating DST_NOCACHE entries.  From Hannes
    Frederic Sowa.

Please pull, thanks a lot!

The following changes since commit 06efe0e54018cb19cf0807447dc3ac747ffcfd1c:

  Merge tag 'pinctrl-v3.19-3' of git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl (2015-01-20 21:23:41 +1200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 06539d3071067ff146a9bffd1c801fa56d290909:

  net: don't OOPS on socket aio (2015-01-27 12:25:33 -0800)

----------------------------------------------------------------
Ahmed S. Darwish (4):
      can: kvaser_usb: Do not sleep in atomic context
      can: kvaser_usb: Send correct context to URB completion
      can: kvaser_usb: Retry the first bulk transfer on -ETIMEDOUT
      can: kvaser_usb: Fix state handling upon BUS_ERROR events

Alexei Starovoitov (2):
      bpf: rcu lock must not be held when calling copy_to_user()
      samples: bpf: relax test_maps check

Andy Shevchenko (1):
      stmmac: prevent probe drivers to crash kernel

Ben Hutchings (8):
      sh_eth: Fix padding of short frames on TX
      sh_eth: Detach net device when stopping queue to resize DMA rings
      sh_eth: Fix crash or memory leak when resizing rings on device that is down
      sh_eth: Fix serialisation of interrupt disable with interrupt & NAPI handlers
      sh_eth: Remove RX overflow log messages
      sh_eth: Ensure DMA engines are stopped before freeing buffers
      sh_eth: Check for DMA mapping errors on transmit
      sh_eth: Fix DMA-API usage for RX buffers

Christoph Hellwig (1):
      net: don't OOPS on socket aio

Daniel Borkmann (3):
      net: cls_bpf: fix size mismatch on filter preparation
      net: cls_bpf: fix auto generation of per list handles
      net: sctp: fix slab corruption from use after free on INIT collisions

David S. Miller (10):
      Merge tag 'wireless-drivers-for-davem-2015-01-20' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 's390'
      Merge tag 'linux-can-fixes-for-3.19-20150121' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'cls_bpf'
      Merge branch 'sh_eth'
      Merge branch 'bpf'
      Merge tag 'mac80211-for-davem-2015-01-23' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'linux-can-fixes-for-3.19-20150127' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'sh_eth'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec

David Spinadel (1):
      iwlwifi: mvm: fix EBS on single scan

Emmanuel Grumbach (2):
      iwlwifi: mvm: drop non VO frames when flushing
      iwlwifi: mvm: abort scheduled scan upon RFKILL

Eric Dumazet (1):
      netxen: fix netxen_nic_poll() logic

Eugene Crosser (1):
      qeth: clean up error handling

Eyal Shapira (1):
      iwlwifi: mvm: set the tx cmd tid for BAR frame correctly

Ezequiel Garcia (1):
      net: mv643xx_eth: Fix highmem support in non-TSO egress path

Felix Fietkau (1):
      ath9k: fix race condition in irq processing during hardware reset

Fred Chou (1):
      mac80211: correct header length calculation

Govindarajulu Varadarajan (2):
      enic: fix rx napi poll return value
      bnx2x: fix napi poll return value for repoll

Hannes Frederic Sowa (2):
      ipv4: try to cache dst_entries which would cause a redirect
      ipv6: replacing a rt6_info needs to purge possible propagated rt6_infos too

Herbert Xu (1):
      udp_diag: Fix socket skipping within chain

Johannes Berg (1):
      nl80211: fix per-station group key get/del and memory leak

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2015-01-13' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'iwlwifi-for-kalle-2015-01-15' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Lendacky, Thomas (1):
      amd-xgbe: Use proper Rx flow control register

Luciano Coelho (1):
      mac80211: only roll back station states for WDS when suspending

Mahesh Bandewar (1):
      ipvlan: fix incorrect usage of IS_ERR() macro in IPv6 code path.

Martin KaFai Lau (1):
      ipv6: Fix __ip6_route_redirect

Mathy Vanhoef (1):
      mac80211: properly set CCK flag in radiotap

Mugunthan V N (1):
      drivers: net: cpsw: discard dual emac default vlan configuration

Nimrod Andy (1):
      ARM: dts: imx6sx: correct i.MX6sx sdb board enet phy address

Sasha Levin (1):
      net: llc: use correct size for sysctl timeout entries

Steffen Klassert (2):
      xfrm6: Fix transport header offset in _decode_session6.
      xfrm6: Fix the nexthdr offset in _decode_session6.

Thomas Richter (1):
      390/qeth: Fix locking warning during qeth device setup

Viktor Babrian (1):
      can: c_can: end pending transmission on network stop (ifdown)

Vivien Didelot (1):
      net: dsa: set slave MII bus PHY mask

subashab@codeaurora.org (1):
      ping: Fix race in free in receive path

 arch/arm/boot/dts/imx6sx-sdb.dts                     |   8 +--
 drivers/net/can/c_can/c_can.c                        |   3 +
 drivers/net/can/usb/kvaser_usb.c                     |  28 ++++-----
 drivers/net/ethernet/amd/xgbe/xgbe-common.h          |   9 +--
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c             |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c      |   2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c          |   2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c           |  59 +++++++++++++++----
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |   5 +-
 drivers/net/ethernet/renesas/sh_eth.c                | 164 ++++++++++++++++++++++++++++++++++++-----------------
 drivers/net/ethernet/renesas/sh_eth.h                |   1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |   5 +-
 drivers/net/ethernet/ti/cpsw.c                       |  22 ++++++++
 drivers/net/ipvlan/ipvlan_core.c                     |   6 +-
 drivers/net/wireless/ath/ath9k/main.c                |   7 +--
 drivers/net/wireless/iwlwifi/iwl-fw-file.h           |   2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h       |   7 ++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c          |  20 +++----
 drivers/net/wireless/iwlwifi/mvm/scan.c              |  53 +++++++++++++----
 drivers/net/wireless/iwlwifi/mvm/tx.c                |  11 +++-
 drivers/s390/net/qeth_core_main.c                    | 117 ++++++++++++++++++++++++++++++++------
 drivers/s390/net/qeth_l2_main.c                      | 220 +++++++++++++++++++++++++++++++++++------------------------------------
 drivers/s390/net/qeth_l3_main.c                      |  50 ++++++++++++----
 include/net/ip.h                                     |  11 ++--
 kernel/bpf/syscall.c                                 |  25 +++++---
 net/dsa/slave.c                                      |   1 +
 net/ipv4/ip_forward.c                                |   3 +-
 net/ipv4/ping.c                                      |   5 +-
 net/ipv4/route.c                                     |   9 +--
 net/ipv4/udp_diag.c                                  |   4 +-
 net/ipv6/ip6_fib.c                                   |  45 ++++++++-------
 net/ipv6/route.c                                     |   6 +-
 net/ipv6/xfrm6_policy.c                              |  10 +++-
 net/llc/sysctl_net_llc.c                             |   8 +--
 net/mac80211/pm.c                                    |  29 +++++-----
 net/mac80211/rx.c                                    |   2 +-
 net/sched/cls_bpf.c                                  |  15 ++++-
 net/sctp/associola.c                                 |   1 -
 net/socket.c                                         |   3 -
 net/wireless/nl80211.c                               |   9 ++-
 net/wireless/util.c                                  |   6 ++
 samples/bpf/test_maps.c                              |   4 +-
 42 files changed, 667 insertions(+), 334 deletions(-)
