From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 06 Jan 2014 17:17:02 -0500 (EST)
Message-ID: <20140106.171702.1996708363894809416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm hoping this is the very last batch of networking fixes for
3.13, here goes nothing:

1) Fix crashes in VLAN's header_ops passthru.

2) Bridge multicast code needs to use BH spinlocks to prevent deadlocks
   with timers.  From Curt Brune.

3) ipv6 tunnels lack proper synchornization when updating percpu statistics.
   From Li RongQing.

4) Fixes to bnx2x driver from Yaniv Rosner, Dmitry Kravkov and Michal
   Kalderon.

5) Avoid undefined operator evaluation order in llc code, from Daniel
   Borkmann.

6) Error paths in various GSO offload paths do not unwind properly, in
   particular they must undo any modifications they have made to the
   SKB.  From Wei-Chun Chao.

7) Fix RX refill races during restore in virtio-net, from Jason Wang.

8) Fix SKB use after free in LLC code, from Daniel Borkmann.

9) Missing unlock and OOPS in netpoll code when VLAN tag handling
   fails.

10) Fix vxlan device attachment wrt. ipv6, from Fan Du.

11) Don't allow creating infiniband links to non-infiniband devices,
    from Hangbin Liu.

12) Revert FEC phy reset active low change, it breaks things.  From
    Fabio Estevam.

13) Fix header pointer handling in 6lowpan header building code, from
    Daniel Borkmann.

14) Fix RSS handling in be2net driver, from Vasundhara Volam.

15) Fix modem port indexing in HSO driver, from Dan Williams.

Please pull, thanks a lot!

The following changes since commit 71ce176ee6ed1735b9a1160a5704a915d13849b1:

  Merge tag 'dt-fixes-for-3.13' of git://git.kernel.org/pub/scm/linux/kernel/git/robh/linux (2013-12-30 14:31:11 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to fe0d692bbc645786bce1a98439e548ae619269f5:

  bridge: use spin_lock_bh() in br_multicast_set_hash_max (2014-01-06 16:39:47 -0500)

----------------------------------------------------------------
Curt Brune (1):
      bridge: use spin_lock_bh() in br_multicast_set_hash_max

Dan Williams (1):
      hso: fix handling of modem port SERIAL_STATE notifications

Daniel Borkmann (3):
      net: llc: fix order of evaluation in llc_conn_ac_inc_vr_by_1
      net: llc: fix use after free in llc_ui_recvmsg
      net: 6lowpan: fix lowpan_header_create non-compression memcpy call

David S. Miller (4):
      vlan: Fix header ops passthru when doing TX VLAN offload.
      netpoll: Fix missing TXQ unlock and and OOPS.
      Merge branch 'bnx2x'
      Merge branch 'be2net'

Dmitry Kravkov (1):
      bnx2x: limit number of interrupt vectors for 57711

Fabio Estevam (1):
      fec: Revert "fec: Do not assume that PHY reset is active low"

Guenter Roeck (1):
      isdn: Drop big endian cpp checks from telespci and hfc_pci drivers

Hangbin Liu (1):
      infiniband: make sure the src net is infiniband when create new link

Hannes Frederic Sowa (1):
      ipv6: don't install anycast address for /128 addresses on routers

Jason Wang (1):
      virtio-net: fix refill races during restore

Josh Boyer (1):
      xen-netback: Include header for vmalloc

Li RongQing (3):
      ipv6: fix the use of pcpu_tstats in sit
      ipv6: fix the use of pcpu_tstats in ip6_tunnel
      ipv6: fix the use of pcpu_tstats in ip6_vti.c

Manish Chopra (2):
      qlcnic: Fix loopback diagnostic test
      qlcnic: Fix resource allocation for TX queues

Michal Kalderon (2):
      bnx2x: Correct number of MSI-X vectors for VFs
      bnx2x: Clean before update RSS arrives

Octavian Purdila (1):
      usbnet: mcs7830: rework link state detection

Shahed Shaikh (1):
      qlcnic: Fix bug in Tx completion path

Suresh Reddy (2):
      be2net: increase the timeout value for loopback-test FW cmd
      be2net: fix max_evt_qs calculation for BE3 in SR-IOV config

Thadeu Lima de Souza Cascardo (1):
      cxgb4: allow large buffer size to have page size

Vasundhara Volam (1):
      be2net: disable RSS when number of RXQs is reduced to 1 via set-channels

Vlad Yasevich (1):
      sctp: Remove outqueue empty state

Wei-Chun Chao (1):
      ipv4: fix tunneled VM traffic over hw VXLAN/GRE GSO NIC

Yaniv Rosner (5):
      bnx2x: Fix 578xx-KR 1G link
      bnx2x: Fix passive DAC cable detection
      bnx2x: Fix Duplex setting for 54618se
      bnx2x: Fix incorrect link-up report
      bnx2x: Fix KR2 work-around detection of BCM8073

Yasushi Asano (1):
      ipv6 addrconf: fix preferred lifetime state-changing behavior while valid_lft is infinity

Yuval Mintz (2):
      bnx2x: fix AFEX memory overflow
      bnx2x: fix VLAN configuration for VFs.

fan.du (1):
      {vxlan, inet6} Mark vxlan_dev flags with VXLAN_F_IPV6 properly

 drivers/infiniband/ulp/ipoib/ipoib_netlink.c         |   3 +-
 drivers/isdn/hisax/hfc_pci.c                         |   4 -
 drivers/isdn/hisax/telespci.c                        |   4 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h          |   7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c     |  94 +++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     |   6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h      |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c       |  15 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h       |   7 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c    | 254 +++++++++++++++++++++++++++++-----------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h    |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c     |  26 +++++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c             |   2 +-
 drivers/net/ethernet/emulex/benet/be.h               |   3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c          |  33 ++++---
 drivers/net/ethernet/emulex/benet/be_main.c          |  29 +++---
 drivers/net/ethernet/freescale/fec_main.c            |  14 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h          |   5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c  |   7 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c     |   4 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c       |  12 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c |   3 +-
 drivers/net/usb/hso.c                                |  13 ++-
 drivers/net/usb/mcs7830.c                            |  19 +---
 drivers/net/virtio_net.c                             |  11 +--
 drivers/net/vxlan.c                                  |   3 +-
 drivers/net/xen-netback/interface.c                  |   1 +
 include/linux/netdevice.h                            |  22 +++++
 include/net/llc_pdu.h                                |   2 +-
 include/net/sctp/structs.h                           |   3 -
 net/8021q/vlan_dev.c                                 |  19 +++-
 net/bridge/br_multicast.c                            |   4 +-
 net/core/neighbour.c                                 |   2 +-
 net/core/netpoll.c                                   |  11 ++-
 net/ieee802154/6lowpan.c                             |   2 +-
 net/ipv4/gre_offload.c                               |  11 ++-
 net/ipv4/udp.c                                       |   6 +-
 net/ipv4/udp_offload.c                               |  37 ++++----
 net/ipv6/addrconf.c                                  |  17 ++--
 net/ipv6/ip6_tunnel.c                                |  21 +++--
 net/ipv6/ip6_vti.c                                   |  24 +----
 net/ipv6/sit.c                                       |   2 +
 net/llc/af_llc.c                                     |   5 +-
 net/sctp/outqueue.c                                  |  32 ++-----
 45 files changed, 478 insertions(+), 327 deletions(-)
