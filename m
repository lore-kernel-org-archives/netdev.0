From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 31 May 2016 20:38:42 -0700 (PDT)
Message-ID: <20160531.203842.926931694819770007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix negative error code usage in ATM layer, from Stefan Hajnoczi.

2) If CONFIG_SYSCTL is disabled, the default TTL is not initialized
   properly.  From Ezequiel Garcia.

3) Missing spinlock init in mvneta driver, from Gregory CLEMENT.

4) Missing unlocks in hwmb error paths, also from Gregory CLEMENT.

5) Fix deadlock on team->lock when propagating features, from Ivan
   Vecera.

6) Work around buffer offset hw bug in alx chips, from Feng Tang.

7) Fix double listing of SCTP entries in sctp_diag dumps, from Xin
   Long.

8) Various statistics bug fixes in mlx4 from Eric Dumazet.

9) Fix some randconfig build errors wrt. fou ipv6 from Arnd Bergmann.

10) All of l2tp was namespace aware, but the ipv6 support code was
    not doing so.  From Shmulik Ladkani.

11) Handle on-stack hrtimers properly in pktgen, from Guenter Roeck.

12) Propagate MAC changes properly through VLAN devices, from Mike
    Manning.

13) Fix memory leak in bnx2x_init_one(), from Vitaly Kuznetsov.

Please pull, thanks a lot!

The following changes since commit 7639dad93a5564579987abded4ec05e3db13659d:

  Merge tag 'trace-v4.7-2' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace (2016-05-22 19:40:39 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to faf8dcc12c2780bfec61eb95e5ad74af2ff4f82f:

  sfc: Track RPS flow IDs per channel instead of per function (2016-05-31 20:30:25 -0700)

----------------------------------------------------------------
Andy Shevchenko (1):
      net/lapb: tuse %*ph to dump buffers

Arnd Bergmann (3):
      ipv6: hide ip6_encap_hlen/ip6_tnl_encap definitions
      fou: add Kconfig options for IPv6 support
      fou: fix IPv6 Kconfig options

Baozeng Ding (2):
      tipc: fix potential null pointer dereferences in some compat functions
      ieee802154: fix logic error in ieee802154_llsec_parse_dev_addr

Chen Haiquan (1):
      vxlan: Accept user specified MTU value when create new vxlan link

Christoph Fritz (1):
      usbnet: smsc95xx: fix link detection for disabled autonegotiation

Dan Carpenter (4):
      qed: signedness bug in qed_dcbx_process_tlv()
      ptp: oops in ptp_ioctl()
      atm: firestream: add more reserved strings
      atm: iphase: off by one in rx_pkt()

Daniel Borkmann (1):
      bpf, inode: disallow userns mounts

David S. Miller (4):
      Merge branch 'hwbm-locking-fixes'
      Merge branch 'dsa-doc-fixes'
      Merge branch 'mlx4-stats-fixes'
      Merge branch 'qed-fixes'

Edward Cree (2):
      sfc: on MC reset, clear PIO buffer linkage in TXQs
      sfc: use flow dissector helpers for aRFS

Elad Kanfi (1):
      net: nps_enet: Disable interrupts before napi reschedule

Eric Dumazet (5):
      net_sched: avoid too many hrtimer_start() calls
      net/mlx4_en: fix tx_dropped bug
      net/mlx4_en: clear some TX ring stats in mlx4_en_clear_stats()
      net/mlx4_en: get rid of ret_stats
      net/mlx4_en: get rid of private net_device_stats

Eric Garver (1):
      Documentation: ip-sysctl.txt: clarify secure_redirects

Ezequiel Garcia (1):
      ipv4: Fix non-initialized TTL when CONFIG_SYSCTL=n

Feng Tang (1):
      net: alx: use custom skb allocator

Florian Fainelli (3):
      Documentation: networking: dsa: Remove poll_link description
      Documentation: networking: dsa: Remove priv_size description
      Documentation: networking: dsa: Describe port_vlan_filtering

Gavin Shan (1):
      net/qlge: Avoids recursive EEH error

Geert Uytterhoeven (1):
      MAINTAINERS: Add file patterns for net device tree bindings

Gregory CLEMENT (2):
      net: mvneta: Fix lacking spinlock initialization
      net: hwbm: Fix unbalanced spinlock in error case

Guenter Roeck (2):
      timer: Export destroy_hrtimer_on_stack()
      net: pktgen: Call destroy_hrtimer_on_stack()

Haishuang Yan (2):
      ip6_gre: Fix MTU setting for ip6gretap
      ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit path.

Ivan Vecera (1):
      team: don't call netdev_change_features under team->lock

Jamal Hadi Salim (1):
      net sched actions: policer missing timestamp processing

Jon Cooper (1):
      sfc: Track RPS flow IDs per channel instead of per function

Marek Vasut (2):
      net: stmmac: Fix incorrect memcpy source memory
      net: arc: trivial: Replace comma with a semicolon

Mike Manning (1):
      vlan: Propagate MAC address to VLANs

Muhammad Falak R Wani (1):
      ptp: use memdup_user().

Shmulik Ladkani (1):
      net: l2tp: Make l2tp_ip6 namespace aware

Simon Horman (1):
      openvswitch: update checksum in {push,pop}_mpls

Stefan Hajnoczi (1):
      net/atm: sk_err_soft must be positive

Sudarsana Reddy Kalluru (3):
      qed: Reset the enable flag for eth protocol.
      qed: Fix allocation in interrupt context
      qed: Prevent 100g from working in MSI

Troy Kisky (1):
      net: fec: update dirty_tx even if no skb

Vidya Sagar Ravipati (1):
      ethtool: add support for 25G/50G/100G speed modes

Vitaly Kuznetsov (1):
      bnx2x: avoid leaking memory on bnx2x_init_one() failures

Xin Long (2):
      sctp: fix double EPs display in sctp_diag
      sctp: sctp_diag should dump sctp socket type

Yuval Mintz (6):
      qede: Fix VF minimum BW setting
      qede: Reload on GRO changes
      qede: Don't expose self-test for VFs
      qed: Save min/max accross dcbx-change
      qed: Add missing 100g init mode
      qed: Don't config min BW on 100g on link flap

wangyunjian (1):
      virtio_net: fix virtnet_open and virtnet_probe competing for try_fill_recv

xypron.glpk@gmx.de (2):
      net: pegasus: simplify logical constraint
      net: hns: avoid null pointer dereference

 Documentation/networking/dsa/dsa.txt              |  17 +++++++-----
 Documentation/networking/ip-sysctl.txt            |   8 +++---
 MAINTAINERS                                       |   1 +
 drivers/atm/firestream.c                          |   6 ++++-
 drivers/atm/iphase.c                              |   2 +-
 drivers/net/ethernet/arc/emac_mdio.c              |   2 +-
 drivers/net/ethernet/atheros/alx/alx.h            |   4 +++
 drivers/net/ethernet/atheros/alx/main.c           |  48 ++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  17 +++++++-----
 drivers/net/ethernet/ezchip/nps_enet.c            |   4 ++-
 drivers/net/ethernet/freescale/fec_main.c         |   8 +++---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  |  11 --------
 drivers/net/ethernet/marvell/mvneta_bm.c          |   1 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  17 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_port.c      |  18 +++++--------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   8 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   3 +--
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |   5 ++--
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  52 +++++++++++++++++++++++++++---------
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  18 +++++++------
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c   |   5 +++-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |  26 +++++++++++++++++-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |   3 ++-
 drivers/net/ethernet/sfc/ef10.c                   |  16 +++++++++++
 drivers/net/ethernet/sfc/efx.c                    |  32 ++++++++++++++++++----
 drivers/net/ethernet/sfc/net_driver.h             |  12 ++++++---
 drivers/net/ethernet/sfc/rx.c                     | 102 +++++++++++++++++++++++++++++-----------------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   2 +-
 drivers/net/team/team.c                           |   9 +++++--
 drivers/net/usb/pegasus.c                         |   2 +-
 drivers/net/usb/smsc95xx.c                        |  51 +++++++++++++++++++++++++++++++++++
 drivers/net/virtio_net.c                          |  18 ++-----------
 drivers/net/vxlan.c                               |   3 +++
 drivers/ptp/ptp_chardev.c                         |  12 +++------
 include/linux/sctp.h                              |   2 ++
 include/net/ip6_tunnel.h                          |   3 ++-
 include/net/pkt_sched.h                           |   1 +
 include/uapi/linux/ethtool.h                      |  11 +++++++-
 include/uapi/linux/pkt_cls.h                      |   4 ++-
 kernel/bpf/inode.c                                |   1 -
 kernel/time/hrtimer.c                             |   1 +
 net/8021q/vlan.c                                  |   5 ++++
 net/8021q/vlan.h                                  |   2 ++
 net/8021q/vlan_dev.c                              |  20 +++++++++++---
 net/atm/signaling.c                               |   2 +-
 net/atm/svc.c                                     |   4 +--
 net/core/hwbm.c                                   |   3 +++
 net/core/pktgen.c                                 |   8 +++---
 net/ieee802154/nl802154.c                         |   4 +--
 net/ipv4/af_inet.c                                |   8 ++++++
 net/ipv4/sysctl_net_ipv4.c                        |   4 ---
 net/ipv6/Kconfig                                  |   9 +++++++
 net/ipv6/Makefile                                 |   2 +-
 net/ipv6/fou6.c                                   |   2 +-
 net/ipv6/ip6_gre.c                                |   3 +++
 net/l2tp/l2tp_ip6.c                               |  12 +++++----
 net/lapb/lapb_in.c                                |   5 ++--
 net/lapb/lapb_out.c                               |   4 +--
 net/lapb/lapb_subr.c                              |  14 ++++------
 net/openvswitch/actions.c                         |  20 ++++++++++----
 net/sched/act_police.c                            |  11 ++++++++
 net/sched/sch_api.c                               |   4 +++
 net/sched/sch_htb.c                               |  13 +++------
 net/sctp/sctp_diag.c                              |   3 +++
 net/sctp/socket.c                                 |   1 +
 net/tipc/netlink_compat.c                         | 111 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------
 67 files changed, 580 insertions(+), 262 deletions(-)
