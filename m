From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 28 Jan 2013 01:03:01 -0500 (EST)
Message-ID: <20130128.010301.1903162087500078263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Much more accumulated than I would have liked due to an
unexpected bout with a nasty flu.

1) AH and ESP input don't set ECN field correctly because the transport
   head of the SKB isn't set correctly, fix from Li RongQing.

2) If netfilter conntrack zones are disabled, we can return an uninitia=
lized
   variable instead of the proper error code.  Fix from Borislav Petkov=
=2E

3) Fix double SKB free in ath9k driver beacon handling, from Felix Feit=
kau.

4) Remove bogus assumption about netns cleanup ordering in nf_conntrack=
,
   from Pablo Neira Ayuso.

5) Remove a bogus BUG_ON in the new TCP fastopen code, from Eric
   Dumazet.  It uses spin_is_locked() in it's test and is therefore
   unsuitable for UP.

6) Fix SELINUX labelling regressions added by the tuntap multiqueue
   changes, from Paul Moore.

7) Fix CRC errors with jumbo frame receive in tg3 driver, from Nithin
   Nayak Sujir.

8) CXGB4 driver sets interrupt coalescing parameters only on first
   queue, rather than all of them.  Fix from Thadeu Lima de Souza
   Cascardo.

9) Fix regression in the dispatch of read/write registers in dm9601
   driver, from Tushar Behera.

10) ipv6_append_data miscalculates header length, from Romain KUNTZ.

11) Fix PMTU handling regressions on ipv4 routes, from Steffen
    Klassert, Timo Ter=E4s, and Julian Anastasov.

12) In 3c574_cs driver, add necessary parenthesis to "x << y & z"
    expression.  From Nickolai Zeldovich.

13) macvlan_get_size() causes underallocation netlink message space,
    fix from Eric Dumazet.

14) Avoid division by zero in xfrm_replay_advance_bmp(), from Nickolai
    Zeldovich.  Amusingly the zero check was already there, we were
    just performing it after the modulus :-)

15) Some more splice bug fixes from Eric Dumazet, which fix things most=
ly
    eminating from how we now more aggressively use high-order pages in
    SKBs.

16) Fix size calculation bug when freeing hash tables in the IPSEC xfrm
    code, from Michal Kubecek.

17) Fix PMTU event propagation into socket cached routes, from Steffen
    Klassert.

18) Fix off by one in TX buffer release in netxen driver, from Eric
    Dumazet.

19) Fix rediculous memory allocation requirements introduced by the
    tuntap multiqueue changes, from Jason Wang.

20) Remove bogus AMD platform workaround in r8169 driver that causes ma=
jor
    problems in normal operation, from Timo Ter=E4s.

21) virtio-net set affinity and select queue don't handle discontiguous
    cpu numbers properly, fix from Wanlong Gao.

22) Fix a route refcounting issue in loopback driver, from Eric Dumazet=
=2E
    There's a similar fix coming that we might add to the macvlan drive=
r
    as well.

23) Fix SKB leaks in batman-adv's distributed arp table code, from
    Matthias Schiffer.

24) r8169 driver gives descriptor ownership back the hardware before we=
're
    done reading the VLAN tag out of it, fix from Francois Romieu.

25) Checksums not calculated properly in GRE tunnel driver fix from
    Pravin B Shelar.

26) Fix SCTP memory leak on namespace exit.

Please pull, thanks a lot!

The following changes since commit 3152ba0f86428cebe8a9f8462d5be0a9aefa=
6289:

  Merge tag 'dt-fixes-for-3.8' of git://sources.calxeda.com/kernel/linu=
x (2013-01-14 13:19:08 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6642f91c92da07369cf1e582503ea3ccb4a7f1a9=
:

  dm9601: support dm9620 variant (2013-01-28 00:18:04 -0500)

----------------------------------------------------------------
AceLan Kao (3):
      Bluetooth: Add support for IMC Networks [13d3:3393]
      Bluetooth: Add support for Foxconn / Hon Hai [0489:e04e]
      Bluetooth: Add support for Foxconn / Hon Hai [0489:e056]

Amitkumar Karwar (2):
      mwifiex: update config_bands during infra association
      mwifiex: correct config_bands handling for ibss network

Anderson Lizardo (1):
      Bluetooth: Fix incorrect strncpy() in hidp_setup_hid()

Avinash Patil (1):
      mwifiex: fix typo in PCIe adapter NULL check

Bj=F8rn Mork (7):
      net: qmi_wwan: add TP-LINK HSUPA Modem MA180
      net: qmi_wwan: add ONDA MT8205 4G LTE
      net: cdc_ncm: workaround for missing CDC Union
      net: cdc_mbim: send ZLP after max sized NTBs
      net: cdc_ncm: fix error path for single interface probing
      net: cdc_mbim: send ZLP only for the specific buggy device
      net: cdc_ncm: use IAD provided by the USB core

Bob Copeland (2):
      mac80211: set NEED_TXPROCESSING for PERR frames
      mac80211: add encrypt headroom to PERR frames

Dan Carpenter (1):
      ip6mr: limit IPv6 MRT_TABLE identifiers

Daniel Schaal (1):
      Bluetooth: Add support for GC-WB300D PCIe [04ca:3006] to ath3k.

Daniel Wagner (1):
      net: net_cls: fd passed in SCM_RIGHTS datagram not set correctly

David S. Miller (6):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'wireless'
      Merge branch 'usb_cdc_fixes'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge

Emmanuel Grumbach (1):
      iwlwifi: audit single frames from AGG queue in RS

Eric Dumazet (7):
      tcp: fix a panic on UP machines in reqsk_fastopen_remove
      macvlan: fix macvlan_get_size()
      tcp: fix incorrect LOCKDROPPEDICMPS counter
      net: splice: avoid high order page splitting
      net: splice: fix __splice_segment()
      netxen: fix off by one bug in netxen_release_tx_buffer()
      net: loopback: fix a dst refcounting issue

=46elix Fietkau (11):
      ath9k: do not link receive buffers during flush
      ath9k: fix double-free bug on beacon generate failure
      ath9k: remove the WARN_ON that triggers if generating a beacon fa=
ils
      ath9k: add a better fix for the rx tasklet vs rx flush race
      ath9k: fix rx flush handling
      ath9k: remove sc->rx.rxbuflock to fix a deadlock
      ath9k: disable the tasklet before taking the PCU lock
      mac80211: fix monitor mode injection
      ath9k_hw: fix calibration issues on chainmask that don't include =
chain 0
      ath9k_hw: fix chain swap setting when setting rx chainmask to 5
      ath9k: allow setting arbitrary antenna masks on AR9003+

Giuseppe CAVALLARO (1):
      net: phy: icplus: fix broken INTR pin settings

Gustavo Padovan (1):
      Bluetooth: Check if the hci connection exists in SCO shutdown

Jacob Keller (2):
      ixgbe: only compile ixgbe_debugfs.o when enabled
      ixgbe: Fix overwriting of rx_mtrl in ixgbe_ptp_hwtstamp_ioctl

Jaganath Kanakkassery (1):
      Bluetooth: Fix authentication if acl data comes before remote fea=
ture evt

Jan Engelhardt (1):
      netfilter: x_tables: print correct hook names for ARP

Jason Wang (2):
      tuntap: reduce memory using of queues
      tuntap: limit the number of flow caches

Jianjun Kong (1):
      net/hyperv: fix wrong length of mac address

Johannes Berg (1):
      mac80211: fix FT roaming

John W. Linville (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Larry Finger (1):
      rtlwifi: Fix build warning introduced by commit a290593

Li RongQing (2):
      ah4/esp4: set transport header correctly for IPsec tunnel mode.
      ah6/esp6: set transport header correctly for IPsec tunnel mode.

Matthias Schiffer (3):
      batman-adv: fix skb leak in batadv_dat_snoop_incoming_arp_reply()
      batman-adv: check for more types of invalid IP addresses in DAT
      batman-adv: filter ARP packets with invalid MAC addresses in DAT

Michal Kubecek (1):
      xfrm: fix freed block size calculation in xfrm_policy_fini()

Neil Horman (1):
      sctp: refactor sctp_outq_teardown to insure proper re-initalizati=
on

Nickolai Zeldovich (2):
      3c574_cs: fix operator precedence between << and &
      net/xfrm/xfrm_replay: avoid division by zero

Nithin Nayak Sujir (2):
      tg3: Avoid null pointer dereference in tg3_interrupt in netconsol=
e mode
      tg3: Fix crc errors on jumbo frame receive

Olivier Sobrie (3):
      can: c_can: fix invalid error codes
      can: ti_hecc: fix invalid error codes
      can: pch_can: fix invalid error codes

Or Gerlitz (1):
      net/mlx4_core: Set number of msix vectors under SRIOV mode to fir=
mware defaults

Pablo Neira Ayuso (2):
      netfilter: xt_CT: fix unset return value if conntrack zone are di=
sabled
      netfilter: nf_conntrack: fix BUG_ON while removing nf_conntrack w=
ith netns

Paul Moore (2):
      selinux: add the "attach_queue" permission to the "tun_socket" cl=
ass
      tun: fix LSM/SELinux labeling of tun/tap devices

Peter Korsgaard (1):
      dm9601: support dm9620 variant

Piotr Haber (1):
      brcmsmac: increase timer reference count for new timers only

Pravin B Shelar (1):
      IP_GRE: Fix kernel panic in IP_GRE with GRE csum.

Rob Herring (1):
      net: calxedaxgmac: throw away overrun frames

Romain KUNTZ (1):
      ipv6: fix header length calculation in ip6_append_data()

Sergio Cambra (1):
      Bluetooth device 04ca:3008 should use ath3k

Stanislaw Gruszka (2):
      mac80211: synchronize scan off/on-channel and PS states
      iwlegacy: fix IBSS cleanup

Stef van Os (1):
      phy/marvell: remove fiber/copper autoselect on 88e1111

Steffen Klassert (7):
      ipv4: Remove output route check in ipv4_mtu
      ipv4: Don't update the pmtu on mtu locked routes
      ipv6: Add an error handler for icmp6
      xfrm4: Invalidate all ipv4 routes on IPsec pmtu events
      ipv4: Invalidate the socket cached route on pmtu events if possib=
le
      ipv4: Add a socket release callback for datagram sockets
      ipv4: Fix route refcount on pmtu discovery

Stephen Hemminger (1):
      MAINTAINERS: Stephen Hemminger email change

Stuart Menefy (1):
      net: phy: icplus: Use the RGMII interface mode to configure clock=
 delays

Sujith Manoharan (1):
      ath9k_htc: Fix memory leak

Szymon Janc (1):
      Bluetooth: Fix sending HCI commands after reset

Thadeu Lima de Souza Cascardo (1):
      cxgb4: set coalesce parameters on all queues

Tilman Schmidt (1):
      isdn/gigaset: fix zero size border case in debug dump

Timo Ter=E4s (1):
      r8169: remove the obsolete and incorrect AMD workaround

Tushar Behera (1):
      usbnet: dm9601: Fix incorrect command

Vlad Yasevich (1):
      SCTP: Free the per-net sysctl table on net exit. v2

Wanlong Gao (3):
      virtio-net: fix the set affinity bug when CPU IDs are not consecu=
tive
      virtio-net: split out clean affinity function
      virtio-net: reset virtqueue affinity when doing cpu hotplug

Wei Shuai (2):
      usbnet: add new flag FLAG_NOARP for usb net devices
      cdc_ncm: add support FLAG_NOARP for Infineon modem platform

Xufeng Zhang (1):
      sctp: set association state to established in dupcook_a handler

Yan Burman (1):
      net/mlx4_en: Fix bridged vSwitch configuration for non SRIOV mode

fran=E7ois romieu (1):
      r8169: fix vlan tag read ordering.

 MAINTAINERS                                           |   6 +--
 drivers/bluetooth/ath3k.c                             |  10 +++++
 drivers/bluetooth/btusb.c                             |   5 +++
 drivers/isdn/gigaset/capi.c                           |   2 +
 drivers/net/can/c_can/c_can.c                         |   4 +-
 drivers/net/can/pch_can.c                             |   2 +-
 drivers/net/can/ti_hecc.c                             |   4 +-
 drivers/net/ethernet/3com/3c574_cs.c                  |   2 +-
 drivers/net/ethernet/broadcom/tg3.c                   |  62 ++++++++++=
++++++++-----------
 drivers/net/ethernet/calxeda/xgmac.c                  |   4 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |  17 ++++++--
 drivers/net/ethernet/intel/ixgbe/Makefile             |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c      |   5 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c          |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c            |  13 ++++--
 drivers/net/ethernet/mellanox/mlx4/main.c             |  11 +-----
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c  |   2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c  |   2 +
 drivers/net/ethernet/realtek/r8169.c                  |  21 +++-------
 drivers/net/hyperv/hyperv_net.h                       |   2 +-
 drivers/net/hyperv/netvsc_drv.c                       |   2 +-
 drivers/net/loopback.c                                |   5 +++
 drivers/net/macvlan.c                                 |   5 ++-
 drivers/net/phy/icplus.c                              |  29 +++++++++-=
----
 drivers/net/phy/marvell.c                             |   9 -----
 drivers/net/tun.c                                     |  45 ++++++++++=
+++++------
 drivers/net/usb/cdc_mbim.c                            |  19 +++++++++
 drivers/net/usb/cdc_ncm.c                             |  31 ++++++++++=
++++-
 drivers/net/usb/dm9601.c                              |  52 ++++++++++=
++++++--------
 drivers/net/usb/qmi_wwan.c                            |   2 +
 drivers/net/usb/usbnet.c                              |   4 ++
 drivers/net/virtio_net.c                              | 118 ++++++++++=
+++++++++++++++++++++++++++++++++++----------
 drivers/net/wireless/ath/ath9k/ar9003_calib.c         |   2 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c           |  27 ++++------=
---
 drivers/net/wireless/ath/ath9k/ath9k.h                |   3 --
 drivers/net/wireless/ath/ath9k/beacon.c               |   2 +-
 drivers/net/wireless/ath/ath9k/debug.c                |   1 -
 drivers/net/wireless/ath/ath9k/debug.h                |   2 -
 drivers/net/wireless/ath/ath9k/htc_hst.c              |   2 +
 drivers/net/wireless/ath/ath9k/hw.h                   |   1 +
 drivers/net/wireless/ath/ath9k/main.c                 |  22 +++++-----=
-
 drivers/net/wireless/ath/ath9k/recv.c                 |  54 +++++++---=
---------------
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c |   7 ++--
 drivers/net/wireless/iwlegacy/common.c                |  35 +++++++---=
-------
 drivers/net/wireless/iwlwifi/dvm/tx.c                 |   2 +
 drivers/net/wireless/mwifiex/cfg80211.c               |  17 +-------
 drivers/net/wireless/mwifiex/pcie.c                   |   2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c              |  14 +++++++
 drivers/net/wireless/rtlwifi/Kconfig                  |   4 +-
 include/linux/security.h                              |  59 ++++++++++=
++++++++++++------
 include/linux/usb/usbnet.h                            |   1 +
 include/net/ip.h                                      |   2 +
 include/net/netfilter/nf_conntrack_core.h             |   2 +
 net/batman-adv/distributed-arp-table.c                |  19 ++++++++-
 net/bluetooth/hci_core.c                              |   8 ----
 net/bluetooth/hci_event.c                             |   2 +-
 net/bluetooth/hidp/core.c                             |   2 +-
 net/bluetooth/l2cap_core.c                            |  11 ++++++
 net/bluetooth/sco.c                                   |   2 +-
 net/core/request_sock.c                               |   2 -
 net/core/scm.c                                        |   5 ++-
 net/core/skbuff.c                                     |  44 ++++++----=
-----------
 net/ipv4/ah4.c                                        |  18 +++++++--
 net/ipv4/datagram.c                                   |  25 ++++++++++=
++
 net/ipv4/esp4.c                                       |  12 ++++--
 net/ipv4/ip_gre.c                                     |   6 ++-
 net/ipv4/ipcomp.c                                     |   7 +++-
 net/ipv4/ping.c                                       |   1 +
 net/ipv4/raw.c                                        |   1 +
 net/ipv4/route.c                                      |  54 ++++++++++=
++++++++++++++-
 net/ipv4/tcp_ipv4.c                                   |   9 ++---
 net/ipv4/udp.c                                        |   1 +
 net/ipv6/ah6.c                                        |  11 +++++-
 net/ipv6/esp6.c                                       |   5 ++-
 net/ipv6/icmp.c                                       |  12 ++++++
 net/ipv6/ip6_output.c                                 |   4 +-
 net/ipv6/ip6mr.c                                      |   3 ++
 net/mac80211/cfg.c                                    |  12 +++++-
 net/mac80211/ieee80211_i.h                            |   6 +--
 net/mac80211/mesh_hwmp.c                              |   5 ++-
 net/mac80211/offchannel.c                             |  19 ++++-----
 net/mac80211/scan.c                                   |  15 +++----
 net/mac80211/tx.c                                     |   9 +++--
 net/netfilter/nf_conntrack_core.c                     |   9 +++--
 net/netfilter/nf_conntrack_standalone.c               |   1 +
 net/netfilter/x_tables.c                              |  28 +++++++++-=
---
 net/netfilter/xt_CT.c                                 |   4 +-
 net/sctp/outqueue.c                                   |  12 ++++--
 net/sctp/sm_statefuns.c                               |   4 +-
 net/sctp/sysctl.c                                     |   4 ++
 net/xfrm/xfrm_policy.c                                |   2 +-
 net/xfrm/xfrm_replay.c                                |   4 +-
 security/capability.c                                 |  24 +++++++++-=
-
 security/security.c                                   |  28 ++++++++++=
---
 security/selinux/hooks.c                              |  50 ++++++++++=
+++++++------
 security/selinux/include/classmap.h                   |   2 +-
 security/selinux/include/objsec.h                     |   4 ++
 97 files changed, 851 insertions(+), 418 deletions(-)
