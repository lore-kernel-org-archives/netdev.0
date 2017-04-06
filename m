From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 05 Apr 2017 18:57:28 -0700 (PDT)
Message-ID: <20170405.185728.133018486572047449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Reject invalid updates to netfilter expectation policies, from
   Pablo Neira Ayuso.

2) Fix memory leak in nfnl_cthelper, from Jeffy Chen.

3) Don't do stupid things if we get a neigh_probe() on a neigh entry
   whose ops lack a solicit method.  From Eric Dumazet.

4) Don't transmit packets in r8152 driver when the carrier is off,
   from Hayes Wang.

5) Fix ipv6 packet type detection in aquantia driver, from Pavel
   Belous.

6) Don't write uninitialized data into hw registers in bna driver,
   from Arnd Bergmann.

7) Fix locking in ping_unhash(), from Eric Dumazet.

8) Make BPF verifier range checks able to understand certain sequences
   emitted by LLVM, from Alexei Starovoitov.

9) Fix use after free in ipconfig, from Mark Rutland.

10) Fix refcount leak on force commit in openvswitch, from Jarno
    Rajahalme.

11) Fix various overflow checks in AF_PACKET, from Andrey Konovalov.

12) Fix endianness bug in be2net driver, from Suresh Reddy.

13) Don't forget to wake TX queues when processing a timeout, from
    Grygorii Strashko.

14) ARP header on-stack storage is wrong in flow dissector, from Simon
    Horman.

15) Lost retransmit and reordering SNMP stats in TCP can be
    underreported.  From Yuchung Cheng.

Please pull, thanks a lot!

The following changes since commit d038e3dcfff6e3de132726a9c7174d8170032aa4:

  Merge tag 'sound-4.11-rc4' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound (2017-03-23 11:58:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to c383bdd14f91562babd269aa7c36b46fee7b6c75:

  nfp: fix potential use after free on xdp prog (2017-04-05 18:46:40 -0700)

----------------------------------------------------------------
Alexander Duyck (2):
      net: Do not allow negative values for busy_read and busy_poll sysctl interfaces
      i40e: Do not enable NAPI on q_vectors that have no rings

Alexei Starovoitov (1):
      bpf: improve verifier packet range checks

Alexey Khoroshilov (1):
      irda: vlsi_ir: fix check for DMA mapping errors

Andrey Konovalov (3):
      net/packet: fix overflow in check for priv area size
      net/packet: fix overflow in check for tp_frame_nr
      net/packet: fix overflow in check for tp_reserve

Arend Van Spriel (2):
      cfg80211: check rdev resume callback only for registered wiphy
      brcmfmac: use local iftype avoiding use-after-free of virtual interface

Arnd Bergmann (5):
      bna: avoid writing uninitialized data into hw registers
      net: hns: fix uninitialized data use
      net: hns: avoid gcc-7.0.1 warning for uninitialized data
      isdn: kcapi: avoid uninitialized data
      rocker: fix Wmaybe-uninitialized false-positive

Colin Ian King (1):
      bnx2x: fix spelling mistake in macros HW_INTERRUT_ASSERT_SET_*

Dan Carpenter (1):
      iwlwifi: mvm: writing zero bytes to debugfs causes a crash

Daniel Borkmann (3):
      bpf, verifier: fix alu ops against map_value{, _adj} register types
      bpf, verifier: fix rejection of unaligned access checks for map_value_adj
      bpf: add various verifier test cases for self-tests

Daode Huang (1):
      net: hns: Add ACPI support to check SFP present

David S. Miller (8):
      Merge branch 'aquantia-fixes'
      Merge branch 's390-net'
      Merge branch 'bnxt_en-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'bpf-map_value_adj-reg-types-fixes'
      Merge tag 'mac80211-for-davem-2017-03-31' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'l2tp_session_find-fixes'
      Merge tag 'wireless-drivers-for-davem-2017-04-03' of git://git.kernel.org/.../kvalo/wireless-drivers

Eric Dumazet (2):
      net: neigh: guard against NULL solicit() method
      ping: implement proper locking

Florian Fainelli (2):
      net: phy: Export mdiobus_register_board_info()
      MAINTAINERS: Add Andrew Lunn as co-maintainer of PHYLIB

Florian Westphal (1):
      secure_seq: downgrade to per-host timestamp offsets

Gao Feng (1):
      netfilter: nf_nat_snmp: Fix panic when snmp_trap_helper fails to register

Grygorii Strashko (1):
      net: ethernet: ti: cpsw: wake tx queues on ndo_tx_timeout

Guillaume Nault (9):
      l2tp: hold tunnel socket when handling control frames in l2tp_ip and l2tp_ip6
      l2tp: purge socket queues in the .destruct() callback
      l2tp: fix race in l2tp_recv_common()
      l2tp: ensure session can't get removed during pppol2tp_session_ioctl()
      l2tp: fix duplicate session creation
      l2tp: hold session while sending creation notifications
      l2tp: take a reference on sessions used in genetlink handlers
      l2tp: take reference on sessions being dumped
      l2tp: fix PPP pseudo-wire auto-loading

Jakub Kicinski (1):
      nfp: fix potential use after free on xdp prog

Jarno Rajahalme (1):
      openvswitch: Fix refcount leak on force commit.

Jeff Kirsher (1):
      Revert "e1000e: driver trying to free already-free irq"

Jeffy Chen (1):
      netfilter: nfnl_cthelper: Fix memory leak

Johannes Berg (1):
      mac80211: unconditionally start new netdev queues with iTXQ support

Jonas Jensen (1):
      net: moxa: fix TX overrun memory leak

Julian Wiedmann (2):
      s390/qeth: size calculation outbound buffers
      s390/qeth: no ETH header for outbound AF_IUCV

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-03-29' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Fix scheduling while atomic splat

Liad Kaufman (1):
      iwlwifi: mvm: support ibss in dqa mode

Liping Zhang (5):
      netfilter: nfnl_cthelper: fix incorrect helper->expect_class_max
      netfilter: invoke synchronize_rcu after set the _hook_ to NULL
      netfilter: nfnl_cthelper: fix a race when walk the nf_ct_helper_hash table
      netfilter: nf_ct_ext: fix possible panic after nf_ct_extend_unregister
      netfilter: nfnetlink_queue: fix secctx memory leak

Marcelo Ricardo Leitner (1):
      tcp: minimize false-positives on TCP/GRO check

Mark Brown (1):
      net/faraday: Explicitly include linux/of.h and linux/property.h

Mark Rutland (1):
      net: ipconfig: fix ic_close_devs() use-after-free

Michael Chan (1):
      bnxt_en: Fix DMA unmapping of the RX buffers in XDP mode during shutdown.

Nathan Sullivan (1):
      net: phy: handle state correctly in phy_stop_machine

Pablo Neira Ayuso (1):
      netfilter: nfnl_cthelper: fix runtime expectation policy updates

Pavel Belous (5):
      net:ethernet:aquantia: Remove adapter re-opening when MTU changed.
      net:ethernet:aquantia: Fix packet type detection (TCP/UDP) for IPv6.
      net:ethernet:aquantia: Missing spinlock initialization.
      net:ethernet:aquantia: Fix for LSO with IPv6.
      net:ethernet:aquantia: Reset is_gso flag when EOP reached.

René Rebe (1):
      r8152: The Microsoft Surface docks also use R8152 v2

Sankar Patchineelam (2):
      bnxt_en: Fix NULL pointer dereference in reopen failure path
      bnxt_en: Correct the order of arguments to netdev_err() in bnxt_set_tpa()

Sara Sharon (1):
      iwlwifi: mvm: fix accessing fw_id_to_mac_id

Sekhar Nori (1):
      net: ethernet: ti: cpsw: fix race condition during open()

Simon Horman (1):
      flow dissector: correct size of storage for ARP

Suresh Reddy (1):
      be2net: Fix endian issue in logical link config command

Talat Batheesh (1):
      net/mlx5: Avoid dereferencing uninitialized pointer

Ursula Braun (1):
      MAINTAINERS: add Julian Wiedmann

WANG Cong (1):
      kcm: return immediately after copy_from_user() failure

Xin Long (5):
      sctp: change to save MSG_MORE flag into assoc
      sctp: alloc stream info when initializing asoc
      sctp: use right in and out stream cnt
      sctp: check for dst and pathmtu update in sctp_packet_config
      sctp: get sock from transport in sctp_transport_update_pmtu

Yi-Hung Wei (1):
      openvswitch: Fix ovs_flow_key_update()

Yuchung Cheng (2):
      tcp: fix lost retransmit SNMP under-counting
      tcp: fix reordering SNMP under-counting

Zakharov Vlad (1):
      ezchip: nps_enet: check if napi has been completed

hayeswang (1):
      r8152: prevent the driver from transmitting packets with carrier off

 MAINTAINERS                                               |   3 +
 drivers/isdn/capi/kcapi.c                                 |   1 +
 drivers/net/ethernet/aquantia/atlantic/aq_main.c          |   5 -
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c           |  23 ++++-
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c          |   1 +
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h          |   3 +-
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c |   4 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c |   4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h               |   6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c          |  18 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                 |  30 ++++--
 drivers/net/ethernet/brocade/bna/bfa_ioc.c                |  10 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c               |   9 +-
 drivers/net/ethernet/ezchip/nps_enet.c                    |   4 +-
 drivers/net/ethernet/faraday/ftgmac100.c                  |   2 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c         |  11 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c        |   6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c        |  28 +++++-
 drivers/net/ethernet/intel/e1000e/netdev.c                |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c               |  16 +++-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c             |   5 +-
 drivers/net/ethernet/moxa/moxart_ether.c                  |  20 +++-
 drivers/net/ethernet/moxa/moxart_ether.h                  |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c       |   3 +-
 drivers/net/ethernet/rocker/rocker_ofdpa.c                |  11 +--
 drivers/net/ethernet/ti/cpsw.c                            |  16 ++--
 drivers/net/irda/vlsi_ir.c                                |   8 +-
 drivers/net/phy/mdio-boardinfo.c                          |   1 +
 drivers/net/phy/phy.c                                     |   2 +-
 drivers/net/usb/cdc_ether.c                               |  15 +++
 drivers/net/usb/r8152.c                                   |  21 ++++-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c    |   8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c          |   2 +
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c         |   3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c         |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c              |   9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c               |   7 +-
 drivers/net/wireless/realtek/rtlwifi/base.c               |   6 +-
 drivers/s390/net/qeth_core.h                              |   3 +-
 drivers/s390/net/qeth_core_main.c                         |   5 +-
 drivers/s390/net/qeth_l2_main.c                           |   5 +-
 drivers/s390/net/qeth_l3_main.c                           |  20 ++--
 include/net/sctp/sctp.h                                   |  22 +++--
 include/net/sctp/structs.h                                |  11 ++-
 kernel/bpf/verifier.c                                     |  64 ++++++++-----
 net/core/flow_dissector.c                                 |   2 +-
 net/core/neighbour.c                                      |   3 +-
 net/core/secure_seq.c                                     |  31 ++++++-
 net/core/sysctl_net_core.c                                |   6 +-
 net/ipv4/ipconfig.c                                       |   2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c                    |  20 +---
 net/ipv4/ping.c                                           |   5 +-
 net/ipv4/tcp_input.c                                      |  41 +++++----
 net/ipv4/tcp_recovery.c                                   |   3 +-
 net/kcm/kcmsock.c                                         |   6 +-
 net/l2tp/l2tp_core.c                                      | 160 +++++++++++++++++++++++++-------
 net/l2tp/l2tp_core.h                                      |   9 +-
 net/l2tp/l2tp_debugfs.c                                   |  10 +-
 net/l2tp/l2tp_eth.c                                       |  10 +-
 net/l2tp/l2tp_ip.c                                        |  22 +++--
 net/l2tp/l2tp_ip6.c                                       |  23 +++--
 net/l2tp/l2tp_netlink.c                                   |  52 +++++++----
 net/l2tp/l2tp_ppp.c                                       |  94 ++++++++++---------
 net/mac80211/iface.c                                      |   3 +-
 net/netfilter/nf_conntrack_ecache.c                       |   2 +
 net/netfilter/nf_conntrack_extend.c                       |  13 ++-
 net/netfilter/nf_conntrack_netlink.c                      |   1 +
 net/netfilter/nf_nat_core.c                               |   2 +
 net/netfilter/nfnetlink_cthelper.c                        | 287 ++++++++++++++++++++++++++++++++++++---------------------
 net/netfilter/nfnetlink_cttimeout.c                       |   2 +-
 net/netfilter/nfnetlink_queue.c                           |   9 +-
 net/openvswitch/conntrack.c                               |   4 +-
 net/openvswitch/flow.c                                    |  10 +-
 net/packet/af_packet.c                                    |   8 +-
 net/sctp/associola.c                                      |  13 ++-
 net/sctp/input.c                                          |   4 +-
 net/sctp/output.c                                         |  69 +++++++-------
 net/sctp/outqueue.c                                       |   3 +-
 net/sctp/proc.c                                           |   4 +-
 net/sctp/sm_make_chunk.c                                  |   9 +-
 net/sctp/sm_statefuns.c                                   |   6 +-
 net/sctp/socket.c                                         |  18 ++--
 net/sctp/stream.c                                         |  43 +++++++--
 net/sctp/transport.c                                      |  19 ++--
 net/wireless/sysfs.c                                      |  10 +-
 tools/include/linux/filter.h                              |  10 ++
 tools/testing/selftests/bpf/Makefile                      |   9 +-
 tools/testing/selftests/bpf/test_verifier.c               | 290 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 88 files changed, 1285 insertions(+), 518 deletions(-)
