From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 08 Aug 2017 23:10:30 -0700 (PDT)
Message-ID: <20170808.231030.1687522425545912677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The pull requests are getting smaller, that's progress I suppose :-)

1) Fix infinite loop in CIPSO option parsing, from Yujuan Qi.

2) Fix remote checksum handling in VXLAN and GUE tunneling drivers,
   from Koichiro Den.

3) Missing u64_stats_init() calls in several drivers, from Florian
   Fainelli.

4) TCP can set the congestion window to an invalid ssthresh value
   after congestion window reductions, from Yuchung Cheng.

5) Fix BPF jit branch generation on s390, from Daniel Borkmann.

6) Correct MIPS ebpf JIT merge, from David Daney.

7) Correct byte order test in BPF test_verifier.c, from Daniel
   Borkmann.

8) Fix various crashes and leaks in ASIX driver, from Dean Jenkins.

9) Handle SCTP checksums properly in mlx4 driver, from Davide
   Caratti.

10) We can potentially enter tcp_connect() with a cached route
    already, due to fastopen, so we have to explicitly invalidate
    it.

11) skb_warn_bad_offload() can bark in legitimate situations, fix
    from Willem de Bruijn.

Please pull, thanks a lot!

The following changes since commit bc78d646e708dabd1744ca98744dea316f459497:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-07-31 22:36:42 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 8d63bee643f1fb53e472f0e135cae4eb99d62d19:

  net: avoid skb_warn_bad_offload false positives on UFO (2017-08-08 21:39:01 -0700)

----------------------------------------------------------------
Anton Volkov (1):
      hysdn: fix to a race condition in put_log_buffer

Bjørn Mork (1):
      qmi_wwan: fix NULL deref on disconnect

Christophe Jaillet (1):
      qed: Fix a memory allocation failure test in 'qed_mcp_cmd_init()'

Daniel Borkmann (3):
      bpf, s390: fix jit branch offset related to ldimm64
      bpf, s390: fix build for libbpf and selftest suite
      bpf: fix byte order test in test_verifier

David Daney (1):
      MIPS: Add missing file for eBPF JIT.

David S. Miller (9):
      Merge branch 'ethernet-ti-cpts-fix-tx-timestamping-timeout'
      Merge branch 'net-Fix-64-bit-statistics-seqcount-init'
      Merge branch 'lan78xx-Fixes'
      Merge branch 'mlx4-misc-fixes'
      Merge tag 'batadv-net-for-davem-20170802' of git://git.open-mesh.org/linux-merge
      Merge branch 'tcp-xmit-timer-rearming'
      Merge branch 'mlxsw-Couple-of-fixes'
      Merge branch 's390-bpf-jit-fixes'
      Merge branch 'asix-Improve-robustness'

Davide Caratti (1):
      net/mlx4_en: don't set CHECKSUM_COMPLETE on SCTP packets

Dean Jenkins (3):
      asix: Add rx->ax_skb = NULL after usbnet_skb_return()
      asix: Ensure asix_rx_fixup_info members are all reset
      asix: Fix small memory leak in ax88772_unbind()

Eric Dumazet (2):
      net: fix keepalive code vs TCP_FASTOPEN_CONNECT
      tcp: fastopen: tcp_connect() must refresh the route

Florian Fainelli (7):
      b44: Initialize 64-bit stats seqcount
      i40e: Initialize 64-bit statistics TX ring seqcount
      ixgbe: Initialize 64-bit stats seqcounts
      nfp: Initialize RX and TX ring 64-bit stats seqcounts
      gtp: Initialize 64-bit per-cpu stats correctly
      netvsc: Initialize 64-bit stats seqcount
      ipvlan: Fix 64-bit statistics seqcount initialization

Grygorii Strashko (4):
      ptp: introduce ptp auxiliary worker
      net: ethernet: ti: cpts: convert to use ptp auxiliary worker
      net: ethernet: ti: cpts: fix tx timestamping timeout
      net: ethernet: ti: cpts: fix fifo read in cpts_find_ts

Guillaume Nault (1):
      ppp: fix xmit recursion detection on ppp channels

Hector Martin (1):
      usb: qmi_wwan: add D-Link DWM-222 device ID

Håkon Bugge (1):
      rds: Reintroduce statistics counting

Ido Schimmel (2):
      mlxsw: spectrum_switchdev: Don't warn about valid situations
      mlxsw: spectrum_switchdev: Release multicast groups during fini

Inbar Karmy (1):
      net/mlx4_en: Fix wrong indication of Wake-on-LAN (WoL) support

Jack Morgenstein (3):
      net/mlx4_core: Fix sl_to_vl_change bit offset in flags2 dump
      net/mlx4_core: Fix namespace misalignment in QinQ VST support commit
      net/mlx4_core: Fixes missing capability bit in flags2 capability dump

John Crispin (1):
      net: dsa: mediatek: add adjust link support for user ports

Julian Wiedmann (1):
      s390/qeth: fix L3 next-hop in xmit qeth hdr

K. Den (2):
      vxlan: fix remcsum when GRO on and CHECKSUM_PARTIAL boundary is outer UDP
      gue: fix remcsum when GRO on and CHECKSUM_PARTIAL boundary is outer UDP

Linus Lüssing (1):
      batman-adv: fix TT sync flag inconsistencies

Neal Cardwell (3):
      tcp: introduce tcp_rto_delta_us() helper for xmit timer fix
      tcp: enable xmit timer fix by having TLP use time when RTO should fire
      tcp: fix xmit timer to only be reset if data ACKed/SACKed

Nisar Sayed (2):
      lan78xx: USB fast connect/disconnect crash fix
      lan78xx: Fix to handle hard_header_len update

Thomas Bogendoerfer (1):
      xgene: Always get clk source, but ignore if it's missing for SGMII ports

Thomas Falcon (1):
      ibmvnic: Initialize SCRQ's during login renegotiation

Thomas Richter (1):
      bpf: fix selftest/bpf/test_pkt_md_access on s390x

Willem de Bruijn (1):
      net: avoid skb_warn_bad_offload false positives on UFO

Xin Long (2):
      ipv6: set rt6i_protocol properly in the route when it is installed
      net: sched: set xt_tgchk_param par.net properly in ipt_init_target

Yuchung Cheng (1):
      tcp: avoid setting cwnd to invalid ssthresh after cwnd reduction states

stephen hemminger (1):
      netvsc: fix race on sub channel creation

yujuan.qi (1):
      Cipso: cipso_v4_optptr enter infinite loop

 arch/mips/net/ebpf_jit.c                                 | 1950 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 arch/s390/net/bpf_jit_comp.c                             |    3 +-
 drivers/isdn/hysdn/hysdn_proclog.c                       |   28 +-
 drivers/net/dsa/mt7530.c                                 |   38 ++
 drivers/net/dsa/mt7530.h                                 |    1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         |    6 +-
 drivers/net/ethernet/broadcom/b44.c                      |    1 +
 drivers/net/ethernet/ibm/ibmvnic.c                       |   15 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c              |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c        |    4 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c          |   15 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c               |   29 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c                  |    9 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h                  |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c                |    2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |   37 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c      |    2 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c                |    2 +-
 drivers/net/ethernet/ti/cpts.c                           |  111 ++++-
 drivers/net/ethernet/ti/cpts.h                           |    2 +-
 drivers/net/gtp.c                                        |    2 +-
 drivers/net/hyperv/hyperv_net.h                          |    3 +-
 drivers/net/hyperv/netvsc.c                              |    3 +
 drivers/net/hyperv/rndis_filter.c                        |   14 +-
 drivers/net/ipvlan/ipvlan_main.c                         |    2 +-
 drivers/net/ppp/ppp_generic.c                            |   18 +-
 drivers/net/usb/asix.h                                   |    1 +
 drivers/net/usb/asix_common.c                            |   53 +-
 drivers/net/usb/asix_devices.c                           |    1 +
 drivers/net/usb/lan78xx.c                                |   18 +-
 drivers/net/usb/qmi_wwan.c                               |    7 +-
 drivers/net/vxlan.c                                      |    1 +
 drivers/ptp/ptp_clock.c                                  |   42 ++
 drivers/ptp/ptp_private.h                                |    3 +
 drivers/s390/net/qeth_l3_main.c                          |    4 +-
 include/linux/mlx4/device.h                              |    1 +
 include/linux/ptp_clock_kernel.h                         |   20 +
 include/net/tcp.h                                        |   10 +
 net/batman-adv/translation-table.c                       |   60 ++-
 net/batman-adv/types.h                                   |    2 +
 net/core/dev.c                                           |    2 +-
 net/ipv4/cipso_ipv4.c                                    |   12 +-
 net/ipv4/fou.c                                           |    1 +
 net/ipv4/tcp_input.c                                     |   34 +-
 net/ipv4/tcp_output.c                                    |   27 +-
 net/ipv4/tcp_timer.c                                     |    3 +-
 net/ipv4/udp_offload.c                                   |    2 +-
 net/ipv6/route.c                                         |   11 +-
 net/ipv6/udp_offload.c                                   |    2 +-
 net/rds/ib_recv.c                                        |    5 +-
 net/sched/act_ipt.c                                      |   20 +-
 tools/build/feature/test-bpf.c                           |    2 +
 tools/lib/bpf/bpf.c                                      |    2 +
 tools/testing/selftests/bpf/test_pkt_md_access.c         |   11 +
 tools/testing/selftests/bpf/test_verifier.c              |   19 +-
 55 files changed, 2490 insertions(+), 186 deletions(-)
 create mode 100644 arch/mips/net/ebpf_jit.c
