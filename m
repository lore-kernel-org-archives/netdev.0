From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 31 Jul 2017 22:16:13 -0700 (PDT)
Message-ID: <20170731.221613.1803481193802381324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Handle notifier registry failures properly in tun/tap driver, from
   Tonghao Zhang.

2) Fix bpf verifier handling of subtraction bounds and add a testcase
   for this, from Edward Cree.

3) Increase reset timeout in ftgmac100 driver, from Ben Herrenschmidt.

4) Fix use after free in prd_retire_rx_blk_timer_exired() in AF_PACKET,
   from Cong Wang.

5) Fix SElinux regression due to recent UDP optimizations, from Paolo
   Abeni.

6) We accidently increment IPSTATS_MIB_FRAGFAILS in the ipv6 code paths,
   fix from Stefano Brivio.

7) Fix some mem leaks in dccp, from Xin Long.

8) Adjust MDIO_BUS kconfig deps to avoid build errors, from Arnd
   Bergmann.

9) Mac address length check and buffer size fixes from Cong Wang.

10) Don't leak sockets in ipv6 udp early demux, from Paolo Abeni.

11) Fix return value when copy_from_user() fails in
    bpf_prog_get_info_by_fd(), from Daniel Borkmann.

12) Handle PHY_HALTED properly in phy library state machine, from
    Florian Fainelli.

13) Fix OOPS in fib_sync_down_dev(), from Ido Schimmel.

14) Fix truesize calculation in virtio_net which led to performance
    regressions, from Michael S. Tsirkin.

Please pull, thanks a lot!

The following changes since commit 96080f697786e0a30006fcbcc5b53f350fcb3e9f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-07-20 16:33:39 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to cc75f8514db6a3aec517760fccaf954e5b46478c:

  samples/bpf: fix bpf tunnel cleanup (2017-07-31 22:02:47 -0700)

----------------------------------------------------------------
Alex Vesker (1):
      net/mlx5e: IPoIB, Modify add/remove underlay QPN flows

Arend Van Spriel (2):
      brcmfmac: fix regression in brcmf_sdio_txpkt_hdalign()
      brcmfmac: fix memleak due to calling brcmf_sdiod_sgtable_alloc() twice

Arnd Bergmann (3):
      net: phy: rework Kconfig settings for MDIO_BUS
      phy: bcm-ns-usb3: fix MDIO_BUS dependency
      tcp: avoid bogus gcc-7 array-bounds warning

Aviv Heller (1):
      net/mlx5: Consider tx_enabled in all modes on remap

Benjamin Herrenschmidt (2):
      ftgmac100: Increase reset timeout
      ftgmac100: Make the MDIO bus a child of the ethernet device

Colin Ian King (1):
      net: tc35815: fix spelling mistake: "Intterrupt" -> "Interrupt"

Dan Carpenter (1):
      iwlwifi: missing error code in iwl_trans_pcie_alloc()

Daniel Borkmann (2):
      bpf: don't indicate success when copy_from_user fails
      bpf: fix bpf_prog_get_info_by_fd to dump correct xlated_prog_len

Daniel Stone (1):
      brcmfmac: Don't grow SKB by negative size

David S. Miller (4):
      Merge branch 'bpf-fix-verifier-min-max-handling-in-BPF_SUB'
      Merge tag 'wireless-drivers-for-davem-2017-07-21' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge tag 'mlx5-fixes-2017-07-27-V2' of git://git.kernel.org/.../saeed/linux
      Merge tag 'wireless-drivers-for-davem-2017-07-28' of git://git.kernel.org/.../kvalo/wireless-drivers

Edward Cree (2):
      selftests/bpf: subtraction bounds test
      bpf/verifier: fix min/max handling in BPF_SUB

Emmanuel Grumbach (3):
      iwlwifi: dvm: prevent an out of bounds access
      iwlwifi: mvm: fix a NULL pointer dereference of error in recovery
      iwlwifi: fix tracing when tx only is enabled

Eran Ben Elisha (1):
      net/mlx5: Clean SRIOV eswitch resources upon VF creation failure

Eugenia Emantayev (7):
      net/mlx5: Fix mlx5_ifc_mtpps_reg_bits structure size
      net/mlx5e: Add field select to MTPPS register
      net/mlx5e: Fix broken disable 1PPS flow
      net/mlx5e: Change 1PPS out scheme
      net/mlx5e: Add missing support for PTP_CLK_REQ_PPS request
      net/mlx5e: Fix wrong delay calculation for overflow check scheduling
      net/mlx5e: Schedule overflow check work to mlx5e workqueue

Florian Fainelli (4):
      net: dsa: Initialize ds->cpu_port_mask earlier
      net: phy: Correctly process PHY_HALTED in phy_stop_machine()
      MAINTAINERS: Add more files to the PHY LIBRARY section
      Revert "net: bcmgenet: Remove init parameter from bcmgenet_mii_config"

Gao Feng (1):
      ppp: Fix a scheduling-while-atomic bug in del_chan

Ido Schimmel (2):
      mlxsw: spectrum_router: Don't offload routes next in list
      ipv4: fib: Fix NULL pointer deref during fib_sync_down_dev()

Ilan Tayari (1):
      net/mlx5e: Fix outer_header_zero() check size

Jakub Kicinski (1):
      bpf: don't zero out the info struct in bpf_obj_get_info_by_fd()

Jason Wang (1):
      Revert "vhost: cache used event for better performance"

Joel Stanley (1):
      ftgmac100: return error in ftgmac100_alloc_rx_buf

Johannes Berg (1):
      iwlwifi: mvm: defer setting IWL_MVM_STATUS_IN_HW_RESTART

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-07-21' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      Revert "rtlwifi: btcoex: rtl8723be: fix ant_sel not work"

Liping Zhang (1):
      openvswitch: fix potential out of bound access in parse_ct

Luca Coelho (1):
      iwlwifi: mvm: handle IBSS probe_queue in a few missing places

Marc Gonzalez (2):
      net: phy: Remove trailing semicolon in macro definition
      net: ethernet: nb8800: Handle all 4 RGMII modes identically

Mark Brown (1):
      net: ethernet: mediatek: Explicitly include linux/interrupt.h

Mark Cave-Ayland (1):
      sunhme: fix up GREG_STAT and GREG_IMASK register offsets

Matthias Kaehlcke (1):
      netpoll: Fix device name check in netpoll_setup()

Michael S. Tsirkin (1):
      virtio_net: fix truesize for mergeable buffers

Mordechai Goodstein (1):
      iwlwifi: pcie: fix unused txq NULL pointer dereference

Moshe Shemesh (2):
      net/mlx5: Fix command completion after timeout access invalid structure
      net/mlx5: Fix command bad flow on command entry allocation failure

Paolo Abeni (5):
      net/socket: fix type in assignment and trim long line
      udp: preserve head state for IP_CMSG_PASSSEC
      udp: unbreak build lacking CONFIG_XFRM
      udp6: fix socket leak on early demux
      udp6: fix jumbogram reception

Paul Blakey (1):
      net/mlx5: Fix mlx5_add_flow_rules call with correct num of dests

Phil Sutter (2):
      lib: test_rhashtable: fix for large entry counts
      lib: test_rhashtable: Fix KASAN warning

Sean Wang (1):
      net: ethernet: mediatek: avoid potential invalid memory access

Sergei Shtylyov (1):
      mv643xx_eth: fix of_irq_to_resource() error check

Stefano Brivio (1):
      ipv6: Don't increase IPSTATS_MIB_FRAGFAILS twice in ip6_fragment()

Sunil Goutham (1):
      net: thunderx: Fix BGX transmit stall due to underflow

Thomas Jarosch (1):
      mcs7780: Fix initialization when CONFIG_VMAP_STACK is enabled

Thor Thayer (1):
      net: stmmac: Adjust dump offset of DMA registers for ethtool

Tonghao Zhang (1):
      tun/tap: Add the missed return value check of register_netdevice_notifier

WANG Cong (4):
      packet: fix use-after-free in prb_retire_rx_blk_timer_expired()
      bonding: commit link status change after propose
      net: check dev->addr_len for dev_set_mac_address()
      team: use a larger struct for mac address

William Tu (1):
      samples/bpf: fix bpf tunnel cleanup

Xin Long (4):
      dccp: fix a memleak that dccp_ipv6 doesn't put reqsk properly
      dccp: fix a memleak that dccp_ipv4 doesn't put reqsk properly
      dccp: fix a memleak for dccp_feat_init err process
      sctp: fix the check for _sctp_walk_params and _sctp_walk_errors

stephen hemminger (1):
      Revert "netvsc: optimize calculation of number of slots"

 MAINTAINERS                                             |  14 +++--
 drivers/net/bonding/bond_main.c                         |   2 +
 drivers/net/ethernet/aurora/nb8800.c                    |   9 ++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.c          |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h          |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c            |   7 +--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c       |  27 ++++++++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h       |   2 +
 drivers/net/ethernet/faraday/ftgmac100.c                |   7 +--
 drivers/net/ethernet/marvell/mv643xx_eth.c              |   2 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c             |   5 ++
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c           |  25 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en.h            |  10 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c      | 222 +++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c       |   1 -
 drivers/net/ethernet/mellanox/mlx5/core/eq.c            |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c       |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c   |  16 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/lag.c           |  25 ++++-----
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h     |   5 ++
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c         |   5 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c   |   7 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c     |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c      |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h         |   3 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c    |   5 ++
 drivers/net/ethernet/sun/sunhme.h                       |   6 +--
 drivers/net/ethernet/toshiba/tc35815.c                  |   2 +-
 drivers/net/hyperv/netvsc_drv.c                         |  43 +++++++++++----
 drivers/net/irda/mcs7780.c                              |  16 ++++--
 drivers/net/phy/Kconfig                                 |  13 +++--
 drivers/net/phy/phy.c                                   |   3 ++
 drivers/net/ppp/pptp.c                                  |   2 +-
 drivers/net/team/team.c                                 |   8 +--
 drivers/net/tun.c                                       |  10 +++-
 drivers/net/virtio_net.c                                |   5 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c |   8 +--
 drivers/net/wireless/intel/iwlwifi/dvm/tx.c             |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-devtrace.h       |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c       |   8 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h            |   2 +
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c            |   6 +--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c            |  15 +++++-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c         |   3 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c            |   3 ++
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c     |   3 --
 drivers/net/wireless/realtek/rtlwifi/wifi.h             |   1 -
 drivers/phy/broadcom/Kconfig                            |   2 +-
 drivers/vhost/vhost.c                                   |  28 +++-------
 drivers/vhost/vhost.h                                   |   3 --
 include/linux/ipv6.h                                    |   6 +++
 include/linux/mlx5/mlx5_ifc.h                           |  10 ++--
 include/linux/phy.h                                     |   2 +-
 include/net/sctp/sctp.h                                 |   4 +-
 include/net/udp.h                                       |  34 ++++++++----
 kernel/bpf/syscall.c                                    |   4 +-
 kernel/bpf/verifier.c                                   |  21 +++++---
 lib/test_rhashtable.c                                   |  57 ++++++++++++--------
 net/core/dev_ioctl.c                                    |   2 +
 net/core/netpoll.c                                      |   2 +-
 net/dccp/feat.c                                         |   7 ++-
 net/dccp/ipv4.c                                         |   1 +
 net/dccp/ipv6.c                                         |   1 +
 net/dsa/dsa2.c                                          |  13 ++---
 net/ipv4/fib_semantics.c                                |   2 +-
 net/ipv4/tcp_output.c                                   |   5 +-
 net/ipv4/udp.c                                          |  41 +++++++-------
 net/ipv6/exthdrs.c                                      |   1 +
 net/ipv6/ip6_output.c                                   |   4 --
 net/ipv6/udp.c                                          |  38 +++++++++----
 net/openvswitch/conntrack.c                             |   7 ++-
 net/packet/af_packet.c                                  |   2 +-
 net/socket.c                                            |   5 +-
 samples/bpf/tcbpf2_kern.c                               |   4 +-
 samples/bpf/test_tunnel_bpf.sh                          |   1 +
 tools/lib/bpf/bpf.c                                     |   1 -
 tools/testing/selftests/bpf/test_progs.c                |   8 ++-
 tools/testing/selftests/bpf/test_verifier.c             |  28 ++++++++++
 80 files changed, 629 insertions(+), 296 deletions(-)
