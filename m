From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 15 Jul 2014 00:28:44 -0700 (PDT)
Message-ID: <20140715.002844.679028486034873225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The latest pile of networking cures:

1) Bluetooth pairing fixes from Johan Hedberg.

2) ieee80211_send_auth() doesn't allocate enough tail room for the SKB,
   from Max Stepanov.

3) New iwlwifi chip IDs, from Oren Givon.

4) bnx2x driver reads wrong PCI config space MSI register, from Yijing =
Wang.

5) IPV6 MLD Query validation isn't strong enough, from Hangbin Liu.

6) Fix double SKB free in openvswitch, from Andy Zhou.

7) Fix sk_dst_set() being racey with UDP sockets, leading to strange
   crashes, from Eric Dumazet.

8) Interpret the NAPI budget correctly in the new systemport driver, fr=
om
   Florian Fainelli.

9) VLAN code frees percpu stats in the wrong place, leading to crashes =
in
   the get stats handler.  From Eric Dumazet.

10) TCP sockets doing a repair can crash with a divide by zero, because=
 we
    invoke tcp_push() with an MSS value of zero.  Just skip that part o=
f
    the sendmsg paths in repair mode.  From Christoph Paasch.

11) IRQ affinity bug fixes in mlx4 driver from Amir Vadai.

12) Don't ignore path MTU icmp messages with a zero mtu, machines out t=
here
    still spit them out, and all of our per-protocol handlers for PMTU =
can
    cope with it just fine.  From Edward Allcutt.

13) Some NETDEV_CHANGE notifier invocations were not passing in the
    correct kind of cookie as the argument, from Loic Prylli.

14) Fix crashes in long multicast/broadcast reassembly, from Jon Paul
    Maloy.

15) ip_tunnel_lookup() doesn't interpret wildcard keys correctly, fix f=
rom
    Dmitry Popov.

16) Fix skb->sk assigned without taking a reference to 'sk' in
    appletalk, from Andrey Utkin.

17) Fix some info leaks in ULP event signalling to userspace in SCTP, f=
rom
    Daniel Borkmann.

18) Fix deadlocks in HSO driver, from Olivier Sobrie.

Please pull, thanks a lot!

The following changes since commit d7933ab727ed035bdf420d7381b831ba959c=
ecc5:

  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6 (2014=
-06-25 21:47:28 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 8f9818af4eaef1150282e18355aaea425474a411=
:

  hso: fix deadlock when receiving bursts of data (2014-07-14 19:27:34 =
-0700)

----------------------------------------------------------------
Alex Wang (1):
      openvswitch: Use exact lookup for flow_get and flow_del.

Alexander Aring (2):
      ieee802154: reassembly: fix possible buffer overflow
      MAINTAINERS: change IEEE 802.15.4 maintainer

Alexey Khoroshilov (1):
      farsync: fix invalid memory accesses in fst_add_one() and fst_ini=
t_card()

Amir Vadai (4):
      net/mlx4_en: Don't use irq_affinity_notifier to track changes in =
IRQ affinity map
      lib/cpumask: cpumask_set_cpu_local_first to use all cores when nu=
ma node is not defined
      net/mlx4_en: IRQ affinity hint is not cleared on port down
      net/mlx4_en: Ignore budget on TX napi polling

Amitkumar Karwar (2):
      mwifiex: fix Tx timeout issue
      mwifiex: initialize Tx/Rx info of a packet correctly

Amritha Nambiar (1):
      GRE: enable offloads for GRE

Andrea Merello (1):
      rt2800usb: Don't perform DMA from stack

Andrey Utkin (1):
      appletalk: Fix socket referencing in skb

Andy Zhou (1):
      openvswitch: Fix a double free bug for the sample action

Arend van Spriel (1):
      brcmfmac: assign chip id and rev in bus interface after brcmf_usb=
_dlneeded

Arik Nemtsov (1):
      Revert "iwlwifi: remove IWL_UCODE_TLV_FLAGS_UAPSD_SUPPORT flag"

Bartosz Markowski (1):
      ath10k: fix 8th virtual AP interface with DFS

Ben Pfaff (2):
      openvswitch: Fix tracking of flags seen in TCP flows.
      netlink: Fix handling of error from netlink_dump().

Bernd Wachter (1):
      net: qmi_wwan: Add ID for Telewell TW-LTE 4G v2

Christoph Paasch (1):
      tcp: Fix divide by zero when pushing during tcp-repair

Christoph Schulz (2):
      net: pppoe: use correct channel MTU when using Multilink PPP
      net: ppp: don't call sk_chk_filter twice

Daniel Borkmann (1):
      net: sctp: fix information leaks in ulpevent layer

Daniel Mack (1):
      net: fix circular dependency in of_mdio code

David S. Miller (7):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'mlx4'
      Merge branch 'stmmac'
      Merge branch 'net_ovs_fixes' of git://git.kernel.org/.../pshelar/=
openvswitch
      Revert "net: stmmac: add platform init/exit for Altera's ARM socf=
pga"
      Merge branch 'xen-netfront'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

David Vrabel (2):
      xen-netfront: don't nest queue locks in xennet_connect()
      xen-netfront: call netif_carrier_off() only once when disconnecti=
ng

Denis Kirjanov (2):
      powerpc: bpf: Use correct mask while accessing the VLAN tag
      powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT test

Dmitry Popov (1):
      ip_tunnel: fix ip_tunnel_lookup

Edward Allcutt (1):
      ipv4: icmp: Fix pMTU handling for rare case

Eliad Peller (2):
      cfg80211: fix elapsed_jiffies calculation
      iwlwifi: mvm: rework sched scan channel configuration

Emmanuel Grumbach (2):
      iwlwifi: dvm: don't enable CTS to self
      iwlwifi: mvm: disable CTS to Self

Eric Dumazet (4):
      ipv4: irq safe sk_dst_[re]set() and ipv4_sk_update_pmtu() fix
      bnx2x: fix possible panic under memory stress
      vlan: free percpu stats in device destructor
      net: fix sparse warning in sk_dst_set()

=46lorian Fainelli (7):
      net: systemport: do not clear IFF_MULTICAST flag
      net: systemport: fix UniMAC reset logic
      net: systemport: fix TX NAPI work done return value
      net: bcmgenet: disable clock before register_netdev
      net: bcmgenet: start with carrier off
      net: bcmgenet: do not set packet length for RX buffers
      net: bcmgenet: fix RGMII_MODE_EN bit

Hangbin Liu (1):
      ipv6: Fix MLD Query message check

Ilan Peer (1):
      iwlwifi: mvm: Fix broadcast filtering

James M Leddy (1):
      udp: Add MIB counters for rcvbuferrors

Jason Wang (1):
      mlx4: mark napi id for gro_skb

Johan Hedberg (3):
      Bluetooth: Fix overriding higher security level in SMP
      Bluetooth: Refactor authentication method lookup into its own fun=
ction
      Bluetooth: Fix rejecting pairing in case of insufficient capabili=
ties

Johannes Berg (2):
      Revert "cfg80211: Use 5MHz bandwidth by default when checking usa=
ble channels"
      nl80211: move set_qos_map command into split state

John W. Linville (7):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'ath-current' of git://github.com/kvalo/ath
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jon Paul Maloy (2):
      tipc: fix bug in multicast/broadcast message reassembly
      tipc: clear 'next'-pointer of message fragments before reassembly

Joonyoung Shim (1):
      usbnet: smsc95xx: add reset_resume function with reset operation

Loic Poulain (1):
      Bluetooth: Ignore H5 non-link packets in non-active state

Loic Prylli (1):
      net: Fix NETDEV_CHANGE notifier usage causing spurious arp flush

Lukasz Rymanowski (1):
      Bluetooth: Fix for ACL disconnect when pairing fails

Maciej W. Rozycki (2):
      defxx: Remove an incorrectly inverted preprocessor conditional
      defxx: Fix !DYNAMIC_BUFFERS compilation warnings

Marcel Holtmann (1):
      Revert "Bluetooth: Add a new PID/VID 0cf3/e005 for AR3012."

Mathias Krause (1):
      neigh: sysctl - simplify address calculation of gc_* variables

Max Stepanov (1):
      mac80211: WEP extra head/tail room in ieee80211_send_auth

Michal Kazior (1):
      ath10k: remove unnecessary htt rx corruption check

Nikolay Aleksandrov (1):
      bonding: fix ad_select module param check

Olivier Sobrie (2):
      hso: remove unused workqueue
      hso: fix deadlock when receiving bursts of data

Or Gerlitz (1):
      net/mlx4_en: Don't configure the HW vxlan parser when vxlan offlo=
ading isn't set

Oren Givon (1):
      iwlwifi: update the 7265 series HW IDs

Rickard Strandqvist (1):
      isdn: hisax: l3ni1.c: Fix for possible null pointer dereference

Stefan Assmann (1):
      igb: do a reset on SR-IOV re-init if device is down

Stefan S=F8rensen (1):
      dp83640: Always decode received status frames

Suresh Reddy (1):
      be2net: set EQ DB clear-intr bit in be_open()

Thomas Fitzsimmons (1):
      net: mvneta: Fix big endian issue in mvneta_txq_desc_csum()

Thomas Petazzoni (1):
      net: mvneta: fix operation in 10 Mbit/s mode

Todd Fujinaka (1):
      igb: Workaround for i210 Errata 25: Slow System Clock

Tom Herbert (1):
      net: Performance fix for process_backlog

Vince Bridgers (3):
      net: stmmac: add platform init/exit for Altera's ARM socfpga
      net: stmmac: Correct duplicate if/then/else case found by cppchec=
k
      net: stmmac: Remove unneeded I/O read caught by cppcheck

Wei Zhang (1):
      openvswitch: supply a dummy err_handler of gre_cisco_protocol to =
prevent kernel crash

Yijing Wang (1):
      bnx2x: Fix the MSI flags

Yuchung Cheng (1):
      tcp: fix false undo corner cases

Zhao Qiang (1):
      powerpc/ucc_geth: deal with a compile warning

dingtianhong (1):
      igmp: fix the problem when mc leave group

fran=E7ois romieu (1):
      MAINTAINERS: update r8169 maintainer

hayeswang (3):
      r8152: wake up the device before dumping the hw counter
      r8169: disable L23
      r8152: fix r8152_csum_workaround function

 MAINTAINERS                                          |   4 +--
 arch/powerpc/net/bpf_jit_comp.c                      |  10 ++++--
 drivers/bluetooth/ath3k.c                            |   2 --
 drivers/bluetooth/btusb.c                            |   1 -
 drivers/bluetooth/hci_h5.c                           |   1 +
 drivers/isdn/hisax/l3ni1.c                           |  14 ++++++---
 drivers/isdn/i4l/isdn_ppp.c                          |   8 +----
 drivers/net/bonding/bond_main.c                      |   2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c           |  43 +++++++----=
---------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c      |   3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c       |  16 ++++------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h       |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c          |   2 +-
 drivers/net/ethernet/freescale/ucc_geth.c            |   4 +--
 drivers/net/ethernet/intel/igb/e1000_82575.c         |   7 +++++
 drivers/net/ethernet/intel/igb/e1000_defines.h       |  18 ++++++-----
 drivers/net/ethernet/intel/igb/e1000_hw.h            |   3 ++
 drivers/net/ethernet/intel/igb/e1000_i210.c          |  66 +++++++++++=
++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_i210.h          |  12 ++++++++
 drivers/net/ethernet/intel/igb/e1000_regs.h          |   1 +
 drivers/net/ethernet/intel/igb/igb_main.c            |  16 ++++++++++
 drivers/net/ethernet/marvell/mvneta.c                |   4 +--
 drivers/net/ethernet/mellanox/mlx4/cq.c              |   2 --
 drivers/net/ethernet/mellanox/mlx4/en_cq.c           |   7 +++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c      |   7 +++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c       |   3 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c           |  17 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c           |  34 ++++++++---=
----------
 drivers/net/ethernet/mellanox/mlx4/eq.c              |  69 +++++------=
------------------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h         |   4 +++
 drivers/net/ethernet/realtek/r8169.c                 |  25 +++++++++++=
++++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |   5 +--
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c       |   2 +-
 drivers/net/fddi/defxx.c                             |  17 +++++------
 drivers/net/phy/dp83640.c                            |   6 ++--
 drivers/net/phy/mdio_bus.c                           |  44 +++++++++++=
+++++++++++++++
 drivers/net/ppp/ppp_generic.c                        |   8 +----
 drivers/net/ppp/pppoe.c                              |   2 +-
 drivers/net/usb/hso.c                                |  50 +++++++++++=
-------------------
 drivers/net/usb/qmi_wwan.c                           |   1 +
 drivers/net/usb/r8152.c                              |   7 ++++-
 drivers/net/usb/smsc95xx.c                           |  14 ++++++++-
 drivers/net/wan/farsync.c                            | 112 +++++++++++=
++++++++++++++++++++++++--------------------------------
 drivers/net/wireless/ath/ath10k/core.c               |   6 +++-
 drivers/net/wireless/ath/ath10k/htt_rx.c             |  18 -----------
 drivers/net/wireless/brcm80211/brcmfmac/usb.c        |   5 +--
 drivers/net/wireless/iwlwifi/dvm/rxon.c              |  12 --------
 drivers/net/wireless/iwlwifi/iwl-fw.h                |   1 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c          |   5 ++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c          |  19 ++++++++---=
-
 drivers/net/wireless/iwlwifi/mvm/scan.c              |  65 +++++++++++=
+---------------------------
 drivers/net/wireless/iwlwifi/pcie/drv.c              |   3 +-
 drivers/net/wireless/mwifiex/11n_aggr.c              |   1 +
 drivers/net/wireless/mwifiex/cfg80211.c              |   1 +
 drivers/net/wireless/mwifiex/cmdevt.c                |   1 +
 drivers/net/wireless/mwifiex/main.c                  |   1 +
 drivers/net/wireless/mwifiex/sta_tx.c                |   1 +
 drivers/net/wireless/mwifiex/tdls.c                  |   2 ++
 drivers/net/wireless/mwifiex/txrx.c                  |   1 +
 drivers/net/wireless/mwifiex/uap_txrx.c              |   1 +
 drivers/net/wireless/rt2x00/rt2800usb.c              |  28 +++++++++++=
++----
 drivers/net/xen-netfront.c                           |  27 +++++++++--=
-----
 drivers/of/of_mdio.c                                 |  34 -----------=
----------
 include/linux/mlx4/device.h                          |   4 +--
 include/linux/of_mdio.h                              |   8 -----
 include/net/neighbour.h                              |   1 -
 include/net/netns/ieee802154_6lowpan.h               |   2 +-
 include/net/sock.h                                   |  12 ++++----
 lib/cpumask.c                                        |   2 +-
 net/8021q/vlan_dev.c                                 |  13 ++++++--
 net/appletalk/ddp.c                                  |   3 --
 net/bluetooth/hci_conn.c                             |  12 +++++++-
 net/bluetooth/smp.c                                  |  60 +++++++++++=
++++++++++++++++---------
 net/core/dev.c                                       |  30 ++++++++++-=
-------
 net/core/neighbour.c                                 |   9 +++---
 net/ipv4/gre_demux.c                                 |   1 +
 net/ipv4/icmp.c                                      |   2 --
 net/ipv4/igmp.c                                      |  10 +++---
 net/ipv4/ip_tunnel.c                                 |  12 +++++---
 net/ipv4/route.c                                     |  15 ++++-----
 net/ipv4/tcp.c                                       |   3 +-
 net/ipv4/tcp_input.c                                 |   8 ++---
 net/ipv4/tcp_output.c                                |   6 ++--
 net/ipv4/udp.c                                       |   5 ++-
 net/ipv6/mcast.c                                     |  13 ++++++--
 net/ipv6/udp.c                                       |   6 +++-
 net/mac80211/util.c                                  |   5 +--
 net/netlink/af_netlink.c                             |   4 +--
 net/openvswitch/actions.c                            |   2 ++
 net/openvswitch/datapath.c                           |  27 ++++++++---=
-----
 net/openvswitch/flow.c                               |   4 +--
 net/openvswitch/flow.h                               |   5 +--
 net/openvswitch/flow_table.c                         |  16 ++++++++++
 net/openvswitch/flow_table.h                         |   3 +-
 net/openvswitch/vport-gre.c                          |  17 +++++++++++
 net/sctp/ulpevent.c                                  | 122 +++++++++--=
--------------------------------------------------------------
 net/tipc/bcast.c                                     |   1 +
 net/tipc/msg.c                                       |  11 +++++--
 net/wireless/core.h                                  |   2 +-
 net/wireless/nl80211.c                               |  11 +++----
 net/wireless/reg.c                                   |  22 +++++------=
--
 102 files changed, 734 insertions(+), 664 deletions(-)
