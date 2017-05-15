From: David Miller <davem@redhat.com>
Subject: [GIT] Networking
Date: Mon, 15 May 2017 16:01:05 -0400 (EDT)
Message-ID: <20170515.160105.58686272515277621.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964854AbdEOUBN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 16:01:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Track alignment in BPF verifier so that legitimate programs won't
   be rejected on !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
   architectures.

2) Make tail calls work properly in arm64 BPF JIT, from Deniel
   Borkmann.

3) Make the configuration and semantics Generic XDP make more
   sense and don't allow both generic XDP and a driver specific
   instance to be active at the same time.  Also from Daniel.

4) Don't crash on resume in xen-netfront, from Vitaly Kuznetsov.

5) Fix use-after-free in VRF driver, from Gao Feng.

6) Use netdev_alloc_skb_ip_align() to avoid unaligned IP headers
   in qca_spi driver, from Stefan Wahren.

7) Always run cleanup routines in BPF samples when we get SIGTERM,
   from Andy Gospodarek.

8) The mdio phy code should bring PHYs out of reset using the shared
   GPIO lines before invoking bus->reset().  From Florian Fainelli.

9) Some USB descriptor access endian fixes in various drivers from
   Johan Hovold.

10) Handle PAUSE advertisements properly in mlx5 driver, from Gal
    Pressman.

11) Fix reversed test in mlx5e_setup_tc(), from Saeed Mahameed.

12) Cure netdev leak in AF_PACKET when using timestamping via control
    messages.  From Douglas Caetano dos Santos.

13) netcp doesn't support HWTSTAMP_FILTER_ALl, reject it.  From
    Miroslav Lichvar.

Please pull, thanks a lot!

The following changes since commit 56868a460b83c0f93d339256a81064d89aadae8e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide (2017-05-09 15:56:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 66f4bc819d71bb600f1c879c9a7161de1cc725f8:

  Merge branch 'ldmsw-fixes' (2017-05-15 15:36:09 -0400)

----------------------------------------------------------------
Andy Gospodarek (1):
      samples/bpf: run cleanup routines when receiving SIGTERM

Bert Kenward (1):
      sfc: revert changes to NIC revision numbers

Chopra, Manish (2):
      qlcnic: Fix link configuration with autoneg disabled
      qlcnic: Update version to 5.3.66

Colin Ian King (2):
      netxen_nic: set rcode to the return status from the call to netxen_issue_cmd
      ethernet: aquantia: remove redundant checks on error status

Daniel Borkmann (3):
      bpf, arm64: fix faulty emission of map access in tail calls
      xdp: add flag to enforce driver mode
      xdp: refine xdp api with regards to generic xdp

David S. Miller (14):
      Merge branch 's390-net-fixes'
      bpf: Track alignment of register values in the verifier.
      bpf: Do per-instruction state dumping in verifier when log_level > 1.
      bpf: Add strict alignment flag for BPF_PROG_LOAD.
      bpf: Add bpf_verify_program() to the library.
      bpf: Add verifier test case for alignment.
      Merge branch 'bpf-pkt-ptr-align'
      bpf: Provide a linux/types.h override for bpf selftests.
      Merge branch 'generic-xdp-followups'
      Merge branch 'qlcnic-fixes'
      bpf: Remove commented out debugging hack in test_align.
      bpf: Handle multiple variable additions into packet pointers in verifier.
      Merge tag 'mlx5-fixes-2017-05-12-V2' of git://git.kernel.org/.../saeed/linux
      Merge branch 'ldmsw-fixes'

Douglas Caetano dos Santos (1):
      net/packet: fix missing net_device reference release

Eric Dumazet (2):
      netem: fix skb_orphan_partial()
      net: sched: optimize class dumps

Florian Fainelli (1):
      net: phy: Call bus->reset() after releasing PHYs from reset

Gal Pressman (2):
      net/mlx5e: Use the correct pause values for ethtool advertising
      net/mlx5e: Fix ethtool pause support and advertise reporting

Gao Feng (1):
      driver: vrf: Fix one possible use-after-free issue

Gustavo A. R. Silva (1):
      net: dsa: mv88e6xxx: add default case to switch

Ivan Khoronzhuk (1):
      net: ethernet: ti: netcp_core: return error while dma channel open issue

Johan Hovold (2):
      net: irda: irda-usb: fix firmware name on big-endian hosts
      net: ch9200: add missing USB-descriptor endianness conversions

Jon Mason (1):
      mdio: mux: Correct mdio_mux_init error path issues

Jon Paul Maloy (1):
      tipc: make macro tipc_wait_for_cond() smp safe

Julia Lawall (1):
      mdio: mux: fix device_node_continue.cocci warnings

Julian Wiedmann (2):
      s390/qeth: unbreak OSM and OSN support
      s390/qeth: avoid null pointer dereference on OSN

Mahesh Bandewar (1):
      ipv6: avoid dad-failures for addresses with NODAD

Mintz, Yuval (1):
      qed: Fix uninitialized data in aRFS infrastructure

Miroslav Lichvar (1):
      net: netcp: fix check of requested timestamping filter

Neil Horman (1):
      vmxnet3: ensure that adapter is in proper state during force_close

Niklas Cassel (1):
      net: stmmac: use correct pointer when printing normal descriptor ring

Saeed Mahameed (2):
      net/mlx5e: Fix setup TC ndo
      net/mlx5e: IPoIB, Only support regular RQ for now

Shannon Nelson (1):
      ldmvsw: stop the clean timer at beginning of remove

Stefan Wahren (1):
      net: qca_spi: Fix alignment issues in rx path

Thomas Tai (1):
      ldmvsw: unregistering netdev before disable hardware

Ursula Braun (2):
      s390/qeth: handle sysfs error during initialization
      s390/qeth: add missing hash table initializations

Vitaly Kuznetsov (1):
      xen-netfront: avoid crashing on resume after a failure in talk_to_netback()

Vlad Yasevich (1):
      macvlan: Fix performance issues with vlan tagged packets

WANG Cong (1):
      ipv6/dccp: do not inherit ipv6_mc_list from parent

Xin Long (1):
      sctp: fix src address selection if using secondary addresses for ipv6

Yishai Hadas (1):
      net/mlx5: Use underlay QPN from the root name space

Yuchung Cheng (1):
      tcp: avoid fragmenting peculiar skbs in SACK

yuval.shaia@oracle.com (1):
      net/mlx4_core: Use min3 to select number of MSI-X vectors

 arch/arm64/net/bpf_jit_comp.c                             |   5 +-
 drivers/net/dsa/mv88e6xxx/chip.c                          |   3 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c |  13 +--
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c |  12 +--
 drivers/net/ethernet/mellanox/mlx4/main.c                 |  10 +--
 drivers/net/ethernet/mellanox/mlx5/core/en.h              |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c      |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c           |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c         |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c          |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h          |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c         |  25 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h         |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c           |  11 ++-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c       |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c       |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h               |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c       |  34 ++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h       |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c       |   3 +
 drivers/net/ethernet/qualcomm/qca_spi.c                   |  10 ++-
 drivers/net/ethernet/sfc/nic.h                            |   8 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c         |   2 +-
 drivers/net/ethernet/sun/ldmvsw.c                         |   4 +-
 drivers/net/ethernet/ti/netcp_core.c                      |   6 +-
 drivers/net/ethernet/ti/netcp_ethss.c                     |   1 -
 drivers/net/irda/irda-usb.c                               |   2 +-
 drivers/net/macvlan.c                                     |   7 +-
 drivers/net/phy/mdio-mux.c                                |  11 +--
 drivers/net/phy/mdio_bus.c                                |   6 +-
 drivers/net/usb/ch9200.c                                  |   4 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                         |   5 ++
 drivers/net/vrf.c                                         |   3 +-
 drivers/net/xen-netfront.c                                |   3 +-
 drivers/s390/net/qeth_core.h                              |   4 +
 drivers/s390/net/qeth_core_main.c                         |  21 +++--
 drivers/s390/net/qeth_core_sys.c                          |  24 ++++--
 drivers/s390/net/qeth_l2.h                                |   2 +
 drivers/s390/net/qeth_l2_main.c                           |  26 ++++--
 drivers/s390/net/qeth_l2_sys.c                            |   8 ++
 drivers/s390/net/qeth_l3_main.c                           |   8 +-
 drivers/soc/ti/knav_dma.c                                 |   2 +-
 include/linux/bpf_verifier.h                              |   4 +
 include/linux/mlx5/fs.h                                   |   4 +-
 include/linux/netdevice.h                                 |   8 +-
 include/uapi/linux/bpf.h                                  |   8 ++
 include/uapi/linux/if_link.h                              |  13 ++-
 kernel/bpf/syscall.c                                      |   5 +-
 kernel/bpf/verifier.c                                     | 133 +++++++++++++++++++++++------
 net/core/dev.c                                            |  57 ++++++++-----
 net/core/rtnetlink.c                                      |  45 +++++-----
 net/core/sock.c                                           |  20 ++---
 net/dccp/ipv6.c                                           |   6 ++
 net/ipv4/tcp_input.c                                      |   9 +-
 net/ipv6/addrconf.c                                       |   5 +-
 net/ipv6/tcp_ipv6.c                                       |   2 +
 net/packet/af_packet.c                                    |  14 +--
 net/sched/sch_api.c                                       |   6 ++
 net/sctp/ipv6.c                                           |  46 ++++++----
 net/tipc/socket.c                                         |  38 ++++-----
 samples/bpf/cookie_uid_helper_example.c                   |   4 +-
 samples/bpf/offwaketime_user.c                            |   1 +
 samples/bpf/sampleip_user.c                               |   1 +
 samples/bpf/trace_event_user.c                            |   1 +
 samples/bpf/tracex2_user.c                                |   1 +
 samples/bpf/xdp1_user.c                                   |   9 +-
 samples/bpf/xdp_tx_iptunnel_user.c                        |   8 +-
 tools/build/feature/test-bpf.c                            |   1 +
 tools/include/uapi/linux/bpf.h                            |  11 ++-
 tools/lib/bpf/bpf.c                                       |  22 +++++
 tools/lib/bpf/bpf.h                                       |   4 +
 tools/testing/selftests/bpf/Makefile                      |   6 +-
 tools/testing/selftests/bpf/include/uapi/linux/types.h    |   6 ++
 tools/testing/selftests/bpf/test_align.c                  | 453 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 74 files changed, 1026 insertions(+), 249 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/include/uapi/linux/types.h
 create mode 100644 tools/testing/selftests/bpf/test_align.c
