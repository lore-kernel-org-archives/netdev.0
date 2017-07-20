From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 20 Jul 2017 16:10:50 -0700 (PDT)
Message-ID: <20170720.161050.1229285512850909272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) BPF verifier signed/unsigned value tracking fix, from Daniel
   Borkmann, Edward Cree, and Josef Bacik.

2) Fix memory allocation length when setting up calls to
   ->ndo_set_mac_address, from Cong Wang.

3) Add a new cxgb4 device ID, from Ganesh Goudar.

4) Fix FIB refcount handling, we have to set it's initial value
   before the configure callback (which can bump it).  From David
   Ahern.

5) Fix double-free in qcom/emac driver, from Timur Tabi.

6) A bunch of gcc-7 string format overflow warning fixes from Arnd
   Bergmann.

7) Fix link level headroom tests in ip_do_fragment(), from Vasily
   Averin.

8) Fix chunk walking in SCTP when iterating over error and parameter
   headers.  From Alexander Potapenko.

9) TCP BBR congestion control fixes from Neal Cardwell.

10) Fix SKB fragment handling in bcmgenet driver, from Doug Berger.

11) BPF_CGROUP_RUN_PROG_SOCK_OPS needs to check for null __sk, from
    Cong Wang.

12) xmit_recursion in ppp driver needs to be per-device not per-cpu,
    from Gao Feng.

13) Cannot release skb->dst in UDP if IP options processing needs it.
    From Paolo Abeni.

14) Some netdev ioctl ifr_name[] NULL termination fixes.  From
    Alexander Levin and myself.

15) Revert some rtnetlink notification changes that are causing
    regressions, from David Ahern.

Please pull, thanks a lot!

The following changes since commit edaf3825182958a1fd5e39708fcb6ea48eca2060:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-07-12 19:30:57 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to cbf5ecb305601d063dc94a57680dfbc3f96c188d:

  net: bonding: Fix transmit load balancing in balance-alb mode (2017-07-20 15:34:40 -0700)

----------------------------------------------------------------
Abhishek Shah (3):
      net: ethernet: bgmac: Remove unnecessary 'return' from platform_bgmac_idm_write
      net: ethernet: bgmac: Make IDM register space optional
      Documentation: devicetree: net: optional idm regs for bgmac

Alexander Potapenko (2):
      sctp: don't dereference ptr before leaving _sctp_walk_{params, errors}()
      ipv4: ipv6: initialize treq->txhash in cookie_v[46]_check()

Arnd Bergmann (6):
      isdn: divert: fix sprintf buffer overflow warning
      net: niu: fix format string overflow warning:
      bnx2x: fix format overflow warning
      net: thunder_bgx: avoid format string overflow warning
      vmxnet3: avoid format strint overflow warning
      liquidio: fix possible eeprom format string overflow

Arun Parameswaran (1):
      dt-binding: ptp: Add SoC compatibility strings for dte ptp clock

Arvind Yadav (10):
      isdn: hisax: constify pci_device_id.
      isdn: hisax: hfc4s8s_l1: constify pci_device_id.
      isdn: hisax: hisax_fcpcipnp: constify pci_device_id.
      isdn: eicon: constify pci_device_id.
      isdn: mISDN: netjet: constify pci_device_id.
      isdn: mISDN: hfcmulti: constify pci_device_id.
      isdn: mISDN: w6692: constify pci_device_id.
      isdn: mISDN: avmfritz: constify pci_device_id.
      isdn: mISDN: hfcpci: constify pci_device_id.
      isdn: avm: c4: constify pci_device_id.

Christophe Jaillet (1):
      atm: zatm: Fix an error handling path in 'zatm_init_one()'

Colin Ian King (5):
      net: broadcom: bnx2x: make a couple of const arrays static
      net: stmmac: make const array route_possibilities static
      rt2x00: make const array glrt_table static
      dccp: make const array error_code static
      net: tehuti: don't process data if it has not been copied from userspace

Dan Carpenter (1):
      netfilter: fix netfilter_net_init() return

Daniel Borkmann (4):
      bpf: fix mixed signed/unsigned derived min/max value bounds
      bpf: allow to specify log level and reduce it for test_verifier
      bpf: fix up test cases with mixed signed/unsigned bounds
      bpf: more tests for mixed signed and unsigned bounds checks

David Ahern (2):
      net: set fib rule refcount after malloc
      Revert "rtnetlink: Do not generate notifications for CHANGEADDR event"

David S. Miller (6):
      Merge branch 'bgmac-stingray-soc'
      Merge branch 'isdn-const-pci_device_ids'
      Merge branch 'bcmgenet-Fragmented-SKB-corrections'
      Merge git://git.kernel.org/.../pablo/nf
      net: Zero terminate ifr_name in dev_ifname().
      Merge branch 'BPF-map-value-adjust-fix'

Doug Berger (2):
      net: bcmgenet: Fix unmapping of fragments in bcmgenet_xmit()
      net: bcmgenet: Free skb after last Tx frag

Edward Cree (1):
      bpf: add test for mixed signed and unsigned bounds checks

Enrico Mioso (1):
      cdc_ncm: Set NTB format again after altsetting switch for Huawei devices

Eugeniy Paltsev (1):
      NET: dwmac: Make dwmac reset unconditional

Florian Fainelli (2):
      dt-bindings: net: Remove duplicate NSP Ethernet MAC binding document
      net: dsa: b53: Add missing ARL entries for BCM53125

Florian Westphal (4):
      netfilter: remove old pre-netns era hook api
      netfilter: nat: fix src map lookup
      netfilter: nf_tables: only allow in/output for arp packets
      netfilter: expect: fix crash when putting uninited expectation

Ganesh Goudar (2):
      cxgb4: add new T5 pci device id's
      cxgb4: ptp_clock_register() returns error pointers

Gao Feng (1):
      ppp: Fix false xmit recursion detect with two ppp devices

Greg Rose (1):
      openvswitch: Fix for force/commit action failures

Håkon Bugge (1):
      rds: Make sure updates to cp_send_gen can be observed

Iván Briano (1):
      net/packet: Fix Tx queue selection for AF_PACKET

Jakub Kicinski (1):
      jhash: fix -Wimplicit-fallthrough warnings

Jason A. Donenfeld (1):
      ioc3-eth: store pointer to net_device for priviate area

Keerthy (1):
      net: ethernet: ti: cpsw: Push the request_irq function to the end of probe

Kefeng Wang (1):
      bpf: fix return in bpf_skb_adjust_net

Kosuke Tatsukawa (1):
      net: bonding: Fix transmit load balancing in balance-alb mode

Levin, Alexander (1):
      wireless: wext: terminate ifr name coming from userspace

LiuJian (1):
      net: hns: add acpi function of xge led control

Mahesh Bandewar (1):
      ipv4: initialize fib_trie prior to register_netdev_notifier call.

Martin Blumenstingl (1):
      mdio: mux: fix parsing mux registers outside of the PHY address range

Martin Hundebøll (1):
      net: dsa: mv88e6xxx: Enable CMODE config support for 6390X

Mateusz Jurczyk (1):
      netfilter: nfnetlink: Improve input length sanitization in nfnetlink_rcv

Neal Cardwell (5):
      tcp_bbr: cut pacing rate only if filled pipe
      tcp_bbr: introduce bbr_bw_to_pacing_rate() helper
      tcp_bbr: introduce bbr_init_pacing_rate_from_rtt() helper
      tcp_bbr: remove sk_pacing_rate=0 transient during init
      tcp_bbr: init pacing rate on first RTT sample

Nikolay Aleksandrov (1):
      net: bridge: fix dest lookup when vlan proto doesn't match

Paolo Abeni (1):
      udp: preserve skb->dst if required for IP options processing

Petr Kulhavy (1):
      smsc95xx: use ethtool_op_get_ts_info()

Rolf Eike Beer (1):
      netlink: correctly document nla_put_u64_64bit()

Roman Mashak (1):
      net sched actions: rename act_get_notify() to tcf_get_notify()

Sabrina Dubroca (1):
      ipv6: avoid overflow of offset in ip6_find_1stfragopt

Thomas Bogendoerfer (1):
      xgene: Don't fail probe, if there is no clk resource for SGMII interfaces

Timur Tabi (1):
      net: qcom/emac: fix double free of SGMII IRQ during shutdown

Vasily Averin (1):
      ipv4: ip_do_fragment: fix headroom tests

WANG Cong (3):
      netpoll: shut up a kernel warning on refcount
      bpf: check NULL for sk_to_full_sk() return value
      rtnetlink: allocate more memory for dev_set_mac_address()

Xin Long (1):
      sctp: fix an array overflow when all ext chunks are set

Zhu Yanjun (1):
      mlx4_en: remove unnecessary returned value check

 Documentation/devicetree/bindings/net/brcm,amac.txt      |   1 +
 Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt |  24 -----
 Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt   |  15 ++-
 drivers/atm/zatm.c                                       |   2 +-
 drivers/isdn/divert/isdn_divert.c                        |  25 ++---
 drivers/isdn/hardware/avm/c4.c                           |   2 +-
 drivers/isdn/hardware/eicon/divasmain.c                  |   2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c                   |   2 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c                   |   2 +-
 drivers/isdn/hardware/mISDN/hfcpci.c                     |   2 +-
 drivers/isdn/hardware/mISDN/netjet.c                     |   2 +-
 drivers/isdn/hardware/mISDN/w6692.c                      |   2 +-
 drivers/isdn/hisax/config.c                              |   2 +-
 drivers/isdn/hisax/hfc4s8s_l1.c                          |   2 +-
 drivers/isdn/hisax/hisax_fcpcipnp.c                      |   2 +-
 drivers/net/bonding/bond_main.c                          |   2 +-
 drivers/net/dsa/b53/b53_common.c                         |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c                         |   1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         |  22 ++--
 drivers/net/ethernet/broadcom/bgmac-platform.c           |  21 ++--
 drivers/net/ethernet/broadcom/bgmac.c                    |  70 +++++++------
 drivers/net/ethernet/broadcom/bgmac.h                    |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c      |   7 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c           | 299 +++++++++++++++++++++++++++---------------------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h           |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c       |   2 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c           |   3 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h       |   2 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c        |   3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c       |  58 ++++++++++-
 drivers/net/ethernet/mellanox/mlx4/alloc.c               |   8 +-
 drivers/net/ethernet/qualcomm/emac/emac.c                |  10 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                      |  14 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c        |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c        |   9 +-
 drivers/net/ethernet/sun/niu.c                           |   4 +-
 drivers/net/ethernet/tehuti/tehuti.c                     |   2 +
 drivers/net/ethernet/ti/cpsw.c                           |  49 ++++-----
 drivers/net/phy/mdio-mux.c                               |   4 +-
 drivers/net/ppp/ppp_generic.c                            |  30 ++++--
 drivers/net/usb/cdc_ncm.c                                |  28 ++++++
 drivers/net/usb/huawei_cdc_ncm.c                         |   6 ++
 drivers/net/usb/smsc95xx.c                               |   1 +
 drivers/net/vmxnet3/vmxnet3_int.h                        |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c           |   2 +-
 include/linux/bpf-cgroup.h                               |   2 +-
 include/linux/bpf_verifier.h                             |   1 +
 include/linux/jhash.h                                    |  29 +++---
 include/linux/netfilter.h                                |   9 --
 include/linux/usb/cdc_ncm.h                              |   1 +
 include/net/netlink.h                                    |   4 +-
 include/net/sctp/sctp.h                                  |   4 +
 kernel/bpf/verifier.c                                    | 108 +++++++++++++++++---
 net/bridge/br_device.c                                   |   3 +-
 net/bridge/br_input.c                                    |   3 +-
 net/core/dev_ioctl.c                                     |   3 +
 net/core/fib_rules.c                                     |   3 +-
 net/core/filter.c                                        |   2 +-
 net/core/netpoll.c                                       |   2 +-
 net/core/rtnetlink.c                                     |   4 +-
 net/dccp/input.c                                         |   2 +-
 net/ipv4/fib_frontend.c                                  |   9 +-
 net/ipv4/ip_output.c                                     |   8 +-
 net/ipv4/netfilter/nf_tables_arp.c                       |   3 +-
 net/ipv4/syncookies.c                                    |   1 +
 net/ipv4/tcp_bbr.c                                       |  49 +++++++--
 net/ipv4/udp.c                                           |  13 ++-
 net/ipv6/output_core.c                                   |   8 +-
 net/ipv6/syncookies.c                                    |   1 +
 net/netfilter/core.c                                     | 147 +--------------------------
 net/netfilter/nf_conntrack_expect.c                      |   2 +-
 net/netfilter/nf_nat_core.c                              |  17 ++--
 net/netfilter/nfnetlink.c                                |   6 +-
 net/openvswitch/conntrack.c                              |  51 +++++++---
 net/packet/af_packet.c                                   |   6 +-
 net/rds/send.c                                           |   6 +-
 net/sched/act_api.c                                      |   4 +-
 net/sctp/sm_make_chunk.c                                 |   4 +-
 tools/lib/bpf/bpf.c                                      |   4 +-
 tools/lib/bpf/bpf.h                                      |   2 +-
 tools/testing/selftests/bpf/test_align.c                 |   2 +-
 tools/testing/selftests/bpf/test_verifier.c              | 480 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 83 files changed, 1176 insertions(+), 581 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
