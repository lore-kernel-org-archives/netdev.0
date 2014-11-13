From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 13 Nov 2014 15:35:52 -0500 (EST)
Message-ID: <20141113.153552.574698345360099703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) sunhme driver lacks DMA mapping error checks, based upon a report
   by Meelis Roos.

2) Fix memory leak in mvpp2 driver, from Sudip Mukherjee.

3) DMA memory allocation sizes are wrong in systemport ethernet
   driver, fix from Florian Fainelli.

4) Fix use after free in mac80211 defragmentation code, from Johannes
   Berg.

5) Some networking uapi headers missing from Kbuild file, from Stephen
   Hemminger.

6) TUN driver gets csum_start offset wrong when VLAN accel is enabled,
   and macvtap has a similar bug, from Herbert Xu.

7) Adjust several tunneling drivers to set dev->iflink after registry,
   because registry sets that to -1 overwriting whatever we did.  From
   Steffen Klassert.

8) Geneve forgets to set inner tunneling type, causing GSO
   segmentation to fail on some NICs.  From Jesse Gross.

9) Fix several locking bugs in stmmac driver, from Fabrice Gasnier and
   Giuseppe CAVALLARO.

10) Fix spurious timeouts with NewReno on low traffic connections, from
    Marcelo Leitner.

11) Fix descriptor updates in enic driver, from Govindarajulu Varadaraj=
an.

12) PPP calls bpf_prog_create() with locks held, which isn't kosher.  F=
ix
    from Takashi Iwai.

13) Fix NULL deref in SCTP with malformed INIT packets, from Daniel
    Borkmann.

14) psock_fanout selftest accesses past the end of the mmap ring, fix
    from Shuah Khan.

15) Fix PTP timestamping for VLAN packets, from Richard Cochran.

16) netlink_unbind() calls in netlink pass wrong initial argument, from
    Hiroaki SHIMODA.

17) vxlan socket reuse accidently reuses a socket when the address fami=
ly
    is different, so we have to explicitly check this, from Marcelo
    Lietner.

18) Fix missing include in nft_reject_bridge.c breaking the build on pp=
c
    and other architectures, from Guenter Roeck.

Please pull, thanks a lot.

The following changes since commit 9f935675d41aa51ebf929fc977cf530ff7d1=
a7fc:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/dtor/input (2014-10-31 19:51:11 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 19ca9fc1445b76b60d34148f7ff837b055f5dcf3=
:

  vxlan: Do not reuse sockets for a different address family (2014-11-1=
3 15:19:59 -0500)

----------------------------------------------------------------
Alexander Kochetkov (2):
      net/smsc911x: Fix rare soft reset timeout issue due to PHY power-=
down mode
      net/smsc911x: Fix delays in the PHY enable/disable routines

Andrew Lunn (1):
      net: dsa: slave: Fix autoneg for phys on switch MDIO bus

Anish Bhatt (2):
      cxgb4 : Fix bug in DCB app deletion
      cxgb4 : dcb open-lldp interop fixes

Brian Hill (1):
      net: phy: Correctly handle MII ioctl which changes autonegotiatio=
n.

Charles Keepax (1):
      asix: Do full reset during ax88772_bind

Chen Gang (2):
      drivers: net: ethernet: xilinx: xilinx_emaclite: Compatible with =
'xlnx, xps-ethernetlite-2.00.b' for QEMU using
      drivers: net: ethernet: xilinx: xilinx_emaclite: revert the origi=
nal commit "1db3ddff1602edf2390b7667dcbaa0f71512e3ea"

Daniel Borkmann (3):
      net: sctp: fix NULL pointer dereference in af->from_addr_param on=
 malformed packet
      net: sctp: fix memory leak in auth key management
      ixgbe: phy: fix uninitialized status in ixgbe_setup_phy_link_tnx

David S. Miller (10):
      sunhme: Add DMA mapping error checks.
      Merge branch 'systemport-net'
      Merge branch 'tun-net'
      Merge branch 'ipv6_tunnel_iflink_init'
      Merge branch 'xgene-net'
      Merge branch 'stmmac-net'
      Merge branch 'mlx5-net'
      Merge tag 'master-2014-11-04' of git://git.kernel.org/.../linvill=
e/wireless
      Merge branch 'cxgb4-net'
      Merge branch 'bcmgenet-net'

Edward Cree (1):
      sfc: don't BUG_ON efx->max_channels =3D=3D 0 in probe

Eli Cohen (2):
      net/mlx5_core: Fix race in create EQ
      net/mlx5_core: Fix race on driver load

Emmanuel Grumbach (2):
      iwlwifi: mvm: initialize the cur_ucode upon boot
      iwlwifi: fix RFkill while calibrating

Enric Balletbo i Serra (1):
      smsc911x: power-up phydev before doing a software reset.

Eric Dumazet (1):
      ipv6: fix IPV6_PKTINFO with v4 mapped

=46abrice Gasnier (2):
      stmmac: fix stmmac_tx_avail should be called with TX locked
      stmmac: release tx lock, in case of dma mapping error.

=46elix Fietkau (1):
      mac80211: flush keys for AP mode on ieee80211_do_stop

=46lorian Fainelli (4):
      net: systemport: fix DMA allocation/freeing sizes
      net: systemport: do not crash freeing an unitialized TX ring
      net: bcmgenet: connect and disconnect from the PHY state machine
      net: bcmgenet: apply MII configuration in bcmgenet_open()

Giuseppe CAVALLARO (3):
      stmmac: fix lock in stmmac_set_rx_mode
      stmmac: fix concurrency in eee initialization.
      stmmac: fix atomicity in pm routines

Govindarajulu Varadarajan (2):
      enic: handle error condition properly in enic_rq_indicate_buf
      enic: update desc properly in rx_copybreak

Gregory Fong (1):
      bridge: include in6.h in if_bridge.h for struct in6_addr

Guenter Roeck (1):
      netfilter: nft_reject_bridge: Fix powerpc build error

Hariprasad Shenai (3):
      cxgb4vf: Move fl_starv_thres into adapter->sge data structure
      cxgb4/cxgb4vf: For T5 use Packing and Padding Boundaries for SGE =
DMA transfers
      cxgb4vf: FL Starvation Threshold needs to be larger than the SGE'=
s Egress Congestion Threshold

Herbert Xu (4):
      tun: Fix csum_start with VLAN acceleration
      tun: Fix TUN_PKT_STRIP setting
      macvtap: Fix csum_start when VLAN tags are present
      lib: rhashtable - Remove weird non-ASCII characters from comments

Hiroaki SHIMODA (1):
      netlink: Properly unbind in error conditions.

Iyappan Subramanian (3):
      dtb: xgene: fix: Backward compatibility with older firmware
      drivers: net: xgene: Backward compatibility with older firmware
      drivers: net: xgene: fix: Use separate resources

Jesse Gross (3):
      geneve: Set GSO type on transmit.
      geneve: Unregister pernet subsys on module unload.
      udptunnel: Add SKB_GSO_UDP_TUNNEL during gro_complete.

Johannes Berg (2):
      mac80211: properly flush delayed scan work on interface removal
      mac80211: fix use-after-free in defragmentation

John W. Linville (2):
      Merge tag 'iwlwifi-for-john-2014-11-03' of git://git.kernel.org/.=
=2E./iwlwifi/iwlwifi-fixes
      Merge tag 'mac80211-for-john-2014-11-04' of git://git.kernel.org/=
=2E../jberg/mac80211

Junjie Mao (1):
      mac80211_hwsim: release driver when ieee80211_register_hw fails

Karl Beldan (1):
      net: mv643xx_eth: reclaim TX skbs only when released by the HW

Linus Walleij (1):
      smc91x: retrieve IRQ and trigger flags in a modern way

Loganaden Velvindron (1):
      net: Add missing descriptions for fwmark_reflect for ipv4 and ipv=
6.

Lothar Wa=DFmann (1):
      net: fec: fix regression on i.MX28 introduced by rx_copybreak sup=
port

Luciano Coelho (2):
      mac80211: use secondary channel offset IE also beacons during CSA
      mac80211: schedule the actual switch of the station before CSA co=
unt 0

Manish Chopra (1):
      netxen: Fix link event handling.

Marcelo Leitner (2):
      tcp: zero retrans_stamp if all retrans were acked
      vxlan: Do not reuse sockets for a different address family

Mugunthan V N (1):
      drivers: net: cpsw: remove cpsw_ale_stop from cpsw_ale_destroy

Nimrod Andy (1):
      net: fec: fix suspend broken on multiple MACs sillicons

Or Gerlitz (1):
      net/mlx4_en: Advertize encapsulation offloads features only when =
VXLAN tunnel is set

Rasmus Villemoes (1):
      include/linux/socket.h: Fix comment

Richard Cochran (1):
      net: ptp: fix time stamp matching logic for VLAN packets.

Ryo Munakata (1):
      net/9p: remove a comment about pref member which doesn't exist

Shuah Khan (1):
      selftests/net: psock_fanout seg faults in sock_fanout_read_ring()

Stefan Wahren (1):
      net: qualcomm: Fix dependency

Steffen Klassert (4):
      ip6_tunnel: Use ip6_tnl_dev_init as the ndo_init function.
      vti6: Use vti6_dev_init as the ndo_init function.
      sit: Use ipip6_tunnel_init as the ndo_init function.
      gre6: Move the setting of dev->iflink into the ndo_init functions=
=2E

Sudip Mukherjee (1):
      net: mvpp2: fix possible memory leak

Takashi Iwai (1):
      net: ppp: Don't call bpf_prog_create() in ppp_lock

stephen hemminger (1):
      uapi: add missing network related headers to kbuild

 Documentation/networking/ip-sysctl.txt               |  14 ++++++++
 arch/arm64/boot/dts/apm-storm.dtsi                   |  10 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c       |  18 +++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h       |   4 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c     |  11 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h     |   5 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c    |   7 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c    |   7 +++-
 drivers/net/ethernet/broadcom/bcmsysport.c           |  13 +++++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.c       |  11 +++++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h       |   3 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c         |   9 ++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c       |  31 +++++++++++=
------
 drivers/net/ethernet/chelsio/cxgb4/sge.c             |  30 +++++++++++=
+++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c           |  51 +++++++++++=
+++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h         |  10 ++++++
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h       |   8 +++++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c           | 136 +++++++++++=
+++++++++++++++++++++++++++++++++++++-------------------------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h   |   2 ++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c       |  28 +++++++++++=
+++-
 drivers/net/ethernet/cisco/enic/enic_main.c          |  20 +++++------
 drivers/net/ethernet/freescale/fec_main.c            |  39 +++++++++++=
+++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c         |   4 +--
 drivers/net/ethernet/marvell/mv643xx_eth.c           |  18 +++++-----
 drivers/net/ethernet/marvell/mvpp2.c                 |  27 ++++++++++-=
----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c       |  22 +++++++----=
-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c         |   7 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c       |   4 +--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |   3 +-
 drivers/net/ethernet/qualcomm/Kconfig                |   3 +-
 drivers/net/ethernet/sfc/ef10.c                      |   3 +-
 drivers/net/ethernet/smsc/smc91x.c                   |  20 ++++++-----
 drivers/net/ethernet/smsc/smsc911x.c                 |  61 +++++++++++=
++++++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  52 +++++++++++=
++++-------------
 drivers/net/ethernet/sun/sunhme.c                    |  62 +++++++++++=
+++++++++++++++++++---
 drivers/net/ethernet/ti/cpsw_ale.c                   |   1 -
 drivers/net/ethernet/ti/cpts.c                       |   2 +-
 drivers/net/macvtap.c                                |   2 ++
 drivers/net/phy/dp83640.c                            |   4 +--
 drivers/net/phy/phy.c                                |  36 +++++++++++=
++-------
 drivers/net/ppp/ppp_generic.c                        |  40 +++++++++++=
-----------
 drivers/net/tun.c                                    |  28 +++++++++--=
----
 drivers/net/usb/asix_devices.c                       |  14 +-------
 drivers/net/vxlan.c                                  |  31 +++++++++++=
------
 drivers/net/wireless/iwlwifi/mvm/fw.c                |  10 +++++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c          |   1 +
 drivers/net/wireless/iwlwifi/mvm/mvm.h               |   1 +
 drivers/net/wireless/iwlwifi/mvm/ops.c               |  12 ++++++-
 drivers/net/wireless/iwlwifi/pcie/trans.c            |   4 +--
 drivers/net/wireless/mac80211_hwsim.c                |   4 ++-
 include/linux/socket.h                               |   2 +-
 include/net/9p/transport.h                           |   1 -
 include/net/udp_tunnel.h                             |   9 +++++
 include/uapi/linux/Kbuild                            |   4 +++
 include/uapi/linux/if_bridge.h                       |   1 +
 lib/rhashtable.c                                     |  10 +++---
 net/bridge/netfilter/nft_reject_bridge.c             |   1 +
 net/dsa/slave.c                                      |   7 ++--
 net/ipv4/fou.c                                       |   2 ++
 net/ipv4/geneve.c                                    |   3 ++
 net/ipv4/ip_sockglue.c                               |   2 +-
 net/ipv4/tcp_input.c                                 |  60 +++++++++++=
+++++----------------
 net/ipv6/ip6_gre.c                                   |   5 +--
 net/ipv6/ip6_tunnel.c                                |  10 +-----
 net/ipv6/ip6_vti.c                                   |  11 +-----
 net/ipv6/sit.c                                       |  15 ++++----
 net/mac80211/ibss.c                                  |   2 +-
 net/mac80211/ieee80211_i.h                           |   3 +-
 net/mac80211/iface.c                                 |  18 ++++++----
 net/mac80211/mesh.c                                  |   2 +-
 net/mac80211/mlme.c                                  |   5 +--
 net/mac80211/rx.c                                    |  14 ++++----
 net/mac80211/spectmgmt.c                             |  18 ++++------
 net/netlink/af_netlink.c                             |   5 +--
 net/sctp/auth.c                                      |   2 --
 net/sctp/sm_make_chunk.c                             |   3 ++
 tools/testing/selftests/net/psock_fanout.c           |   2 +-
 77 files changed, 784 insertions(+), 376 deletions(-)
