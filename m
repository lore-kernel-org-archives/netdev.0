From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 10 Nov 2015 17:07:58 -0500 (EST)
Message-ID: <20151110.170758.1632060919791327087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix null deref in xt_TEE netfilter module, from Eric Dumazet.

2) Several spots need to get to the original listner for SYN-ACK
   packets, most spots got this ok but some were not.  Whilst covering
   the remaining cases, create a helper to do this.  From Eric Dumazet.

3) Missiing check of return value from alloc_netdev() in CAIF SPI code,
   from Rasmus Villemoes.

4) Don't sleep while !=3D TASK_RUNNING in macvtap, from Vlad Yasevich.

5) Use after free in mvneta driver, from Justin Maggard.

6) Fix race on dst->flags access in dst_release(), from Eric Dumazet.

7) Add missing ZLIB_INFLATE dependency for new qed driver.  From Arnd
   Bergmann.

8) Fix multicast getsockopt deadlock, from WANG Cong.

9) Fix deadlock in btusb, from Kuba Pawlak.

10) Some ipv6_add_dev() failure paths were not cleaning up the SNMP6
    counter state.  From Sabrina Dubroca.

11) Fix packet_bind() race, which can cause lost notifications,
    from Francesco Ruggeri.

12) Fix MAC restoration in qlcnic driver during bonding mode changes,
    from Jarod Wilson.

13) Revert bridging forward delay change which broke libvirt and other
    userspace things, from Vlad Yasevich.

Please pull, thanks a lot!

The following changes since commit 1b1050cdc5cdde43177b375b5f22dc070d45=
d8f8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide (2015-1=
1-04 10:12:43 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 8a921265e2cd31e61a0c2eda582af54c5bfef897=
:

  Revert "bridge: Allow forward delay to be cfgd when STP enabled" (201=
5-11-10 15:41:36 -0500)

----------------------------------------------------------------
Arnd Bergmann (4):
      NFC: nfcmrvl: fix SPI driver dependencies
      bnxt_en: add VXLAN dependency
      mvneta: add FIXED_PHY dependency
      qed: select ZLIB_INFLATE

Dan Carpenter (3):
      qlogic/qed: remove bogus NULL check
      qlogic: qed: fix a test for MODE_MF_SI
      qlogic: qed: fix error codes in qed_resc_alloc()

David Ahern (1):
      net: Fix prefsrc lookups

David S. Miller (5):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'bnxt_en-fixes'
      Merge tag 'nfc-fixes-4.4-1' of git://git.kernel.org/.../sameo/nfc=
-fixes
      Merge branch 'skb_to_full_sk'

Eric Dumazet (12):
      netfilter: xt_TEE: fix NULL dereference
      tcp: fix req->saved_syn race
      ipv4: use sk_fullsock() in ipv4_conntrack_defrag()
      tcp: use correct req pointer in tcp_move_syn() calls
      selinux: fix random read in selinux_ip_postroute_compat()
      net: add skb_to_full_sk() helper and use it in selinux_netlbl_skb=
uff_setsid()
      smack: use skb_to_full_sk() helper
      netfilter: xt_owner: use skb_to_full_sk() helper
      sched: cls_flow: use skb_to_full_sk() helper
      net_sched: em_meta: use skb_to_full_sk() helper
      netfilter: nft_meta: use skb_to_full_sk() helper
      net: fix a race in dst_release()

=46lorian Westphal (1):
      netfilter: nfnetlink: don't probe module if it exists

=46rancesco Ruggeri (1):
      packet: race condition in packet_bind

Geert Uytterhoeven (1):
      net: hisilicon: NET_VENDOR_HISILICON should depend on HAS_DMA

Iyappan Subramanian (1):
      drivers: net: xgene: fix RGMII 10/100Mb mode

Jarod Wilson (2):
      net/core: ensure features get disabled on new lower devs
      net/qlcnic: fix mac address restore in bond mode 5/6

Jay Vosburgh (1):
      bonding: fix panic on non-ARPHRD_ETHER enslave failure

Jeffrey Huang (3):
      bnxt_en: Change sp events definitions to represent bit position.
      bnxt_en: map CAG_REG_LEGACY_INT_STATUS_MASK to GRC window #4
      bnxt_en: More robust SRIOV cleanup sequence.

Jiri Pirko (1):
      net: add forgotten IFF_L3MDEV_SLAVE define

Johan Hedberg (3):
      Bluetooth: L2CAP: Fix returning correct LE CoC response codes
      Bluetooth: L2CAP: Fix checked range when allocating new CID
      Bluetooth: L2CAP: Add missing checks for invalid LE DCID

Justin Maggard (1):
      net: mvneta: Fix memory use after free.

Kuba Pawlak (1):
      Bluetooth: Fix possible deadlock in btusb

LABBE Corentin (1):
      net: stmmac: fix double-initialization of phy_iface

Marcel Holtmann (1):
      Bluetooth: Check for supported white list before issuing commands

Markus Brunner (1):
      drivers: net: cpsw: Add support for fixed-link PHY

Markus Elfring (2):
      fjes: Delete an unnecessary check before the function call "vfree=
"
      dwc_eth_qos: Delete an unnecessary check before the function call=
 "of_node_put"

Michael Chan (2):
      bnxt_en: Determine tcp/ipv6 RSS hash type correctly.
      bnxt_en: Fix comparison of u16 sw_id against negative value.

Munehisa Kamata (1):
      netfilter: nf_nat_redirect: add missing NULL pointer check

Niklas Cassel (1):
      net: Documentation: Fix default value tcp_limit_output_bytes

Petr =A6tetiar (1):
      USB: qmi_wwan: Add quirk for Quectel EC20 Mini PCIe module

Rasmus Villemoes (1):
      net: caif: check return value of alloc_netdev

Sabrina Dubroca (1):
      ipv6: clean up dev_snmp6 proc entry when we fail to initialize in=
et6_dev

Sergei Shtylyov (2):
      sh_eth: kill 'ret' variable in sh_eth_ring_init()
      sh_eth: merge sh_eth_free_dma_buffer() into sh_eth_ring_free()

Stefan Hajnoczi (1):
      VSOCK: call sk->sk_data_ready() on accept()

Steven Rostedt (1):
      bpf_trace: Make dependent on PERF_EVENTS

Tobias Klauser (1):
      tun_dst: Fix potential NULL dereference

Vincent Cuissard (5):
      NFC: nfcmrvl: avoid UART break control during FW download
      NFC: nfcmrvl: add a small wait after setting UART break
      NFC: nfcmrvl: free reset gpio
      NFC: nfcmrvl: remove unneeded CONFIG_OF switches
      NFC: nfcmrvl: avoid being stuck on FW dnld timeout

Vivien Didelot (1):
      net: dsa: mv88e6xxx: isolate unbridged ports

Vlad Yasevich (2):
      macvtap: Resolve possible __might_sleep warning in macvtap_do_rea=
d()
      Revert "bridge: Allow forward delay to be cfgd when STP enabled"

WANG Cong (2):
      ipv4: disable BH when changing ip local port range
      ipv4: fix a potential deadlock in mcast getsockopt() path

Yang Shi (2):
      bpf: add mod default A and X test cases
      bpf: doc: correct arch list for supported eBPF JIT

 Documentation/devicetree/bindings/net/cpsw.txt   |   5 ++++
 Documentation/networking/filter.txt              |   6 ++--
 Documentation/networking/ip-sysctl.txt           |   2 +-
 drivers/bluetooth/btusb.c                        |   6 ++--
 drivers/net/bonding/bond_main.c                  |   1 +
 drivers/net/caif/caif_spi.c                      |   7 +++--
 drivers/net/dsa/mv88e6171.c                      |   2 ++
 drivers/net/dsa/mv88e6352.c                      |   2 ++
 drivers/net/dsa/mv88e6xxx.c                      |  42 +++++++++++++++=
+++++++++++++
 drivers/net/dsa/mv88e6xxx.h                      |   2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  49 +++++++++++++++=
+++++++++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |   1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |   1 -
 drivers/net/ethernet/broadcom/Kconfig            |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        |  28 ++++++++++++++-=
----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h        |  26 ++++++++++-----=
--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c  |  40 +++++++++++++++=
++---------
 drivers/net/ethernet/hisilicon/Kconfig           |   3 +-
 drivers/net/ethernet/marvell/Kconfig             |   1 +
 drivers/net/ethernet/marvell/mvneta.c            |   2 +-
 drivers/net/ethernet/qlogic/Kconfig              |   1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c        |  14 +++++++---
 drivers/net/ethernet/qlogic/qed/qed_int.c        |   5 ----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   3 +-
 drivers/net/ethernet/renesas/sh_eth.c            |  84 +++++++++++++++=
+++++-----------------------------------
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c   |   2 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c      |   3 +-
 drivers/net/ethernet/ti/cpsw.c                   |  13 +++++++++
 drivers/net/fjes/fjes_hw.c                       |   4 +--
 drivers/net/macvtap.c                            |   5 ++--
 drivers/net/usb/qmi_wwan.c                       |  21 ++++++++++++++
 drivers/nfc/nfcmrvl/Kconfig                      |   2 +-
 drivers/nfc/nfcmrvl/fw_dnld.c                    |  12 ++++++--
 drivers/nfc/nfcmrvl/main.c                       |  15 ++--------
 drivers/nfc/nfcmrvl/uart.c                       |  26 ++++++---------=
--
 include/linux/netdevice.h                        |   1 +
 include/linux/tcp.h                              |   7 +++++
 include/net/bluetooth/l2cap.h                    |   2 ++
 include/net/dst_metadata.h                       |   3 +-
 include/net/inet_sock.h                          |  12 ++++++++
 kernel/trace/Kconfig                             |   2 +-
 lib/test_bpf.c                                   |  30 +++++++++++++++=
+++++
 net/bluetooth/hci_core.c                         |  17 +++++++----
 net/bluetooth/l2cap_core.c                       |  20 +++++++++++--
 net/bridge/br_stp.c                              |  13 ++++++---
 net/core/dev.c                                   |   7 +++--
 net/core/dst.c                                   |   2 +-
 net/ipv4/fib_semantics.c                         |  13 +++++++--
 net/ipv4/igmp.c                                  |  12 +++-----
 net/ipv4/ip_sockglue.c                           |  45 +++++++++++++++=
+++++----------
 net/ipv4/netfilter/nf_defrag_ipv4.c              |   5 ++--
 net/ipv4/sysctl_net_ipv4.c                       |   4 +--
 net/ipv4/tcp_ipv4.c                              |   2 ++
 net/ipv4/tcp_minisocks.c                         |   3 --
 net/ipv6/addrconf.c                              |   1 +
 net/ipv6/tcp_ipv6.c                              |  20 +++++++------
 net/netfilter/nf_nat_redirect.c                  |   2 +-
 net/netfilter/nfnetlink.c                        |   2 +-
 net/netfilter/nft_meta.c                         |  36 +++++++++++++--=
---------
 net/netfilter/xt_TEE.c                           |   6 ++--
 net/netfilter/xt_owner.c                         |   6 ++--
 net/packet/af_packet.c                           |  80 +++++++++++++++=
+++++++++++++++++--------------------
 net/sched/cls_flow.c                             |  15 +++++++---
 net/sched/em_meta.c                              | 138 +++++++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++--------------------------=
----
 net/vmw_vsock/vmci_transport.c                   |   2 +-
 security/selinux/hooks.c                         |   6 ++--
 security/selinux/netlabel.c                      |   2 +-
 security/smack/smack_netfilter.c                 |  11 +++++---
 68 files changed, 642 insertions(+), 322 deletions(-)
