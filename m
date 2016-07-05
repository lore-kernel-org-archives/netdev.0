From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 05 Jul 2016 16:23:54 -0700 (PDT)
Message-ID: <20160705.162354.2087159317908923178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) All users of AF_PACKET's fanout feature want a symmetric packet
   header hash for load balancing purposes, so give it to them.

2) Fix vlan state synchronization in e1000e, from Jarod Wilson.

3) Use correct socket pointer in ip_skb_dst_mtu(), from Shmulik
   Ladkani.

4) mlx5 bug fixes from Mohamad Haj Yahia, Daniel Jurgens, Matthew
   Finlay, Rana Shahout, and Shaker Daibes.  Mostly to do with
   operation timeouts and PCI error handling.

5) Fix checksum handling in mirred packet action, from WANG Cong.

6) Set skb->dev correctly when transmitting in !protect_frames case
   of macsec driver, from Daniel Borkmann.

7) Fix MTU calculation in geneve driver, from Haishuang Yan.

8) Missing netif_napi_del() in unregister path of qeth driver, from
   Ursula Braun.

9) Handle malformed route netlink messages in decnet properly, from
   Vergard Nossum.

10) Memory leak of percpu data in ipv6 routing code, from Martin
    KaFai Lau.

Please pull, thanks a lot!

The following changes since commit e7bdea7750eb2a64aea4a08fa5c0a31719c8=
155d:

  Merge tag 'nfs-for-4.7-2' of git://git.linux-nfs.org/projects/anna/li=
nux-nfs (2016-06-29 15:30:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to 903ce4abdf374e3365d93bcb3df56c62008835ba=
:

  ipv6: Fix mem leak in rt6i_pcpu (2016-07-05 14:09:23 -0700)

----------------------------------------------------------------
Aviv Heller (1):
      bonding: fix enslavement slave link notifications

Bj=F8rn Mork (1):
      cdc_ncm: workaround for EM7455 "silent" data interface

Christophe Jaillet (1):
      fsl/fman: fix error handling

Daniel Borkmann (1):
      macsec: set actual real device for xmit when !protect_frames

Daniel Jurgens (5):
      net/mlx5: Fix incorrect page count when in internal error
      net/mlx5: Fix wait_vital for VFs and remove fixed sleep
      net/mlx5e: Timeout if SQ doesn't flush during close
      net/mlx5e: Implement ndo_tx_timeout callback
      net/mlx5e: Handle RQ flush in error cases

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue
      Merge branch 'mlx5-fixes'
      packet: Use symmetric hash for PACKET_FANOUT_HASH.
      Revert "fsl/fman: fix error handling"

Eric Dumazet (1):
      bonding: prevent out of bound accesses

=46lorian Fainelli (1):
      net: bcmsysport: Device stats are unsigned long

Ganesh Goudar (1):
      cxgb4: update latest firmware version supported

Haishuang Yan (1):
      geneve: fix max_mtu setting

Jarod Wilson (1):
      e1000e: keep Rx/Tx HW_VLAN_CTAG in sync

Martin KaFai Lau (1):
      ipv6: Fix mem leak in rt6i_pcpu

Matt Corallo (1):
      net: stmmac: Fix null-function call in ISR on stmmac1000

Matthew Finlay (1):
      net/mlx5e: Copy all L2 headers into inline segment

Mohamad Haj Yahia (4):
      net/mlx5: Fix teardown errors that happen in pci error handler
      net/mlx5: Avoid calling sleeping function by the health poll thre=
ad
      net/mlx5: Fix potential deadlock in command mode change
      net/mlx5: Add timeout handle to commands with callback

Or Gerlitz (1):
      net/mlx5: Avoid setting unused var when modifying vport node GUID

Rana Shahout (2):
      net/mlx5e: Fix select queue callback
      net/mlx5e: Validate BW weight values of ETS

Richard Alpe (1):
      tipc: fix nl compat regression for link statistics

Russell King - ARM Linux (1):
      net: mvneta: fix open() error cleanup

Sergio Valverde (1):
      enc28j60: Fix race condition in enc28j60 driver

Shaker Daibes (1):
      net/mlx5e: Log link state changes

Shmulik Ladkani (1):
      ipv4: Fix ip_skb_dst_mtu to use the sk passed by ip_finish_output

Sony Chacko (1):
      qlcnic: add wmb() call in transmit data path.

Soohoon Lee (1):
      usbnet: Stop RX Q on MTU change

Stefan Hauser (1):
      net: phy: dp83867: Fix initialization of PHYCR register

Ursula Braun (1):
      qeth: delete napi struct when removing a qeth device

Vegard Nossum (2):
      RDS: fix rds_tcp_init() error path
      net: fix decnet rtnexthop parsing

WANG Cong (1):
      net_sched: fix mirrored packets checksum

Xin Long (1):
      ixgbevf: ixgbevf_write/read_posted_mbx should use IXGBE_ERR_MBX t=
o initialize ret_val

hayeswang (2):
      r8152: clear LINK_OFF_WAKE_EN after autoresume
      r8152: fix runtime function for RTL8152

 drivers/net/bonding/bond_3ad.c                      |  11 ++++---
 drivers/net/bonding/bond_alb.c                      |   7 ++---
 drivers/net/bonding/bond_main.c                     |   1 +
 drivers/net/ethernet/broadcom/bcmsysport.c          |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h   |  12 +++----
 drivers/net/ethernet/intel/e1000e/netdev.c          |  21 ++++++------=
-
 drivers/net/ethernet/intel/ixgbevf/mbx.c            |   4 +--
 drivers/net/ethernet/marvell/mvneta.c               |   2 ++
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c       | 129 ++++++++++++=
++++++++++++++++++++++++++++++---------------------------------
 drivers/net/ethernet/mellanox/mlx5/core/en.h        |  11 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c  |   8 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  99 ++++++++++++=
+++++++++++++++++++++++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c     |  41 ++++++++++++=
++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c     |  52 ++++++++++++=
+++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/health.c    |  11 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c      |  41 +++++++++---=
------------
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c |  63 ++++++++++++=
++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/vport.c     |   3 --
 drivers/net/ethernet/microchip/enc28j60.c           |   7 +++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c      |   2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c   |   2 +-
 drivers/net/geneve.c                                |   9 ++++--
 drivers/net/macsec.c                                |   1 +
 drivers/net/phy/dp83867.c                           |  13 +++++---
 drivers/net/usb/cdc_ncm.c                           |   7 +++++
 drivers/net/usb/r8152.c                             |  35 ++++++++++++=
++++-----
 drivers/net/usb/usbnet.c                            |  10 ++++--
 drivers/s390/net/qeth_l2_main.c                     |   1 +
 drivers/s390/net/qeth_l3_main.c                     |   1 +
 include/linux/mlx5/driver.h                         |   1 +
 include/linux/skbuff.h                              |  20 ++++++++++++
 include/net/bonding.h                               |   7 ++++-
 include/net/ip.h                                    |   5 ++-
 net/bridge/br_netfilter_hooks.c                     |   2 +-
 net/core/flow_dissector.c                           |  43 ++++++++++++=
+++++++++++++
 net/core/skbuff.c                                   |  18 -----------
 net/decnet/dn_fib.c                                 |  21 +++++++-----=
-
 net/ipv4/ip_output.c                                |   4 +--
 net/ipv6/ip6_fib.c                                  |   1 +
 net/packet/af_packet.c                              |   2 +-
 net/rds/tcp.c                                       |   5 +--
 net/sched/act_mirred.c                              |   2 +-
 net/tipc/netlink_compat.c                           |   2 +-
 43 files changed, 527 insertions(+), 212 deletions(-)
