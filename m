From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 01 Feb 2016 14:28:43 -0800 (PST)
Message-ID: <20160201.142843.19985627861663318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It looks like a lot but it's a mixture of regression fixes as well as f=
ixes
for longer standing issues.

1) Fix on-channel cancellation in mac80211, from Johannes Berg.

2) Handle CHECKSUM_COMPLETE properly in xt_TCPMSS netfilter xtables mod=
ule,
   from Eric Dumazet.

3) Avoid infinite loop in UDP SO_REUSEPORT logic, also from Eric Dumaze=
t.

4) Avoid a NULL deref if we try to set SO_REUSEPORT after a socket is
   bound, from Craig Gallek.

5) GRO key comparisons don't take lightweight tunnels into account, fro=
m
   Jesse Gross.

6) Fix struct pid leak via SCM credentials in AF_UNIX, from Eric Dumaze=
t.

7) We need to set the rtnl_link_ops of ipv6 SIT tunnels before we regis=
ter
   them, otherwise the NEWLINK netlink message is missing the proper
   attributes.  From Thadeu Lima de Souza Cascardo.

8) Several Spectrum chip bug fixes for mlxsw switch driver, from Ido Sc=
himmel

9) Handle fragments properly in ipv4 easly socket demux, from Eric Duma=
zet.

10) Don't ignore the ifindex key specifier on ipv6 output route lookups=
,
    from Paolo Abeni.

Please pull, thanks a lot!

The following changes since commit a200dcb34693084e56496960d855afdeaaf9=
578f:

  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/mst/vhost (2016-01-18 16:44:24 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net=20

for you to fetch changes up to 53729eb174c1589f9185340ffe8c10b3f39f3ef3=
:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/bluetooth/bluetooth (2016-01-30 15:32:42 -0800)

----------------------------------------------------------------
Alexander Duyck (1):
      fib_trie: Fix shift by 32 in fib_table_lookup

Andrew Lunn (3):
      of: of_mdio: Ensure mdio device is a PHY
      of: of_mdio: Add a whitelist of PHY compatibilities.
      DT: phy.txt: Clarify expected compatible values

Arnd Bergmann (11):
      ssb: mark ssb_bus_register as __maybe_unused
      net: simplify napi_synchronize() to avoid warnings
      net: i40e: shut up uninitialized variable warnings
      ipv4: ipconfig: avoid unused ic_proto_used symbol
      net: moxart: use correct accessors for DMA memory
      net: davinci_cpdma: use dma_addr_t for DMA address
      net: hp100: remove unnecessary #ifdefs
      net: bgmac: clarify CONFIG_BCMA dependency
      net: vxge: avoid unused function warnings
      net: nb8800: avoid uninitialized variable warning
      net: tg3: avoid uninitialized variable warning

Bernie Harris (1):
      net_sched: drr: check for NULL pointer in drr_dequeue

Bob Copeland (1):
      Revert "mac80211_hwsim: support any address in userspace"

Craig Gallek (1):
      soreuseport: fix NULL ptr dereference SO_REUSEPORT after bind

Dave Young (1):
      wireless: change cfg80211 regulatory domain info as debug message=
s

David S. Miller (14):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'fix-phy-ignore-interrupts'
      Merge branch 'mvneta-multi-clk'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue
      Merge branch 'mlxsw-fixes'
      Merge branch 'sctp-transport-races'
      Merge tag 'mac80211-for-davem-2016-01-26' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'lan78xx-fixes'
      Merge branch 'phylib-regressions-part-2'
      Merge branch 'bnxt_en-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-01-29' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'ipv6-sticky-pktinfo'
      Merge branch 'arnd-net-driver-fixes'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth

Eli Cooper (1):
      rt2x00: fix monitor mode regression

Eliad Peller (3):
      mac80211: avoid ROC during hw restart
      mac80211: clear local->sched_scan_req properly on reconfig
      mac80211: handle sched_scan_stopped vs. hw restart race

Emmanuel Grumbach (1):
      mac80211: fix PS-Poll handling

Eric Dumazet (8):
      netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in tcpmss_tg6()
      udp: fix potential infinite loop in SO_REUSEPORT logic
      net: diag: support v4mapped sockets in inet_diag_find_one_icsk()
      tcp: fix NULL deref in tcp_v4_send_ack()
      af_unix: fix struct pid memory leak
      i40e: fix build warnings
      tcp: beware of alignments in tcp_get_info()
      ipv4: early demux should be aware of fragments

=46elix Fietkau (2):
      brcmfmac: add missing include
      ath9k_hw: ignore eeprom magic mismatch on flash based devices

=46lorian Fainelli (3):
      net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS
      net: phy: Fix phy_mac_interrupt()
      net: bcmgenet: Properly configure PHY to ignore interrupt

=46lorian Westphal (2):
      netfilter: nft_byteorder: avoid unneeded le/be conversion steps
      netfilter: ipset: allow a 0 netmask with hash_netiface type

Glenn Ruben Bakke (1):
      Bluetooth: 6lowpan: Fix kernel NULL pointer dereferences

Gregory Greenman (1):
      iwlwifi: mvm: rs: fix TPC statistics handling

Haiyang Zhang (1):
      hv_netvsc: Fix book keeping of skb during batching process

Hannes Frederic Sowa (1):
      pptp: fix illegal memory access caused by multiple bind()s

Hante Meuleman (1):
      brcmfmac: fix sdio sg table alloc crash

Helmut Schaa (1):
      mac80211: Don't buffer non-bufferable MMPDUs

Ido Schimmel (12):
      mlxsw: spectrum: Handle port leaving LAG while bridged
      mlxsw: reg: Add the Switch Filtering DB Flush register
      mlxsw: spectrum: Flush FDB when leaving bridge
      mlxsw: spectrum: Don't forward packets when STP state is DISABLED
      mlxsw: spectrum: Disable learning according to STP state
      mlxsw: spectrum: Notify bridge's FDB only based on learning_sync
      mlxsw: spectrum: Don't report VLAN for 802.1D FDB entries
      mlxsw: spectrum: Use correct netdev when notifying bridge
      mlxsw: spectrum: Dump LAG FDB records only once
      mlxsw: spectrum: Compare local ports instead of pointers
      mlxsw: reg: Use correct offset in field definiton
      switchdev: Require RTNL mutex to be held when sending FDB notific=
ations

Iyappan Subramanian (1):
      drivers: net: xgene: fix extra IRQ issue

Jesse Gross (2):
      gro: Make GRO aware of lightweight tunnels.
      tunnels: Allow IPv6 UDP checksums to be correctly controlled.

Jisheng Zhang (5):
      net: mvneta: fix trivial cut-off issue in mvneta_ethtool_update_s=
tats
      net: mvneta: sort the headers in alphabetic order
      net: mvneta: Try to get named core clock first
      net: mvneta: get optional bus clk
      net: mvneta: update clocks property and document additional clock=
-names

Joe Stringer (1):
      inet: frag: Always orphan skbs inside ip_defrag()

Johan Hedberg (4):
      Bluetooth: L2CAP: Introduce proper defines for PSM ranges
      Bluetooth: L2CAP: Fix auto-allocating LE PSM values
      Bluetooth: L2CAP: Fix setting chan src info before adding PSM/CID
      Bluetooth: Fix incorrect removing of IRKs

Johannes Berg (6):
      mac80211: recalculate SW ROC only when needed
      mac80211: fix remain-on-channel cancellation
      regulatory: fix world regulatory domain data
      net: fec: make driver endian-safe
      net: fec: use CONFIG_ARM instead of CONFIG_ARCH_MXC/SOC_IMX28
      rfkill: fix rfkill_fop_read wait_event usage

Johannes Weiner (1):
      net: sock: remove dead cgroup methods from struct proto

J=F6rg Thalheim (1):
      tcp: Change reference to experimental CWND RFC.

Kalle Valo (2):
      Merge ath-current from ath.git
      Merge tag 'iwlwifi-for-kalle-2016-01-26_2' of https://git.kernel.=
org/.../iwlwifi/iwlwifi-fixes

Kefeng Wang (2):
      net: cavium: liquidio: use helpers ns_to_timespec64()
      ptp: ixp46x: use helpers for converting ns to timespec

Ken-ichirou MATSUZAWA (1):
      netlink: not trim skb for mmaped socket when dump

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix 5G failure when EEPROM is incorrectly enc=
oded

Li RongQing (1):
      vxlan: fix a out of bounds access in __vxlan_find_mac

Lukasz Duda (1):
      Bluetooth: 6lowpan: Fix handling of uncompressed IPv6 packets

Malcolm Crossley (1):
      xen-netfront: request Tx response events more often

Manfred Rudigier (1):
      net: dp83640: Fix tx timestamp overflow handling.

Marcel Holtmann (1):
      Bluetooth: Add missing COMPATIBLE_IOCTL for UART line discipline

Marcelo Ricardo Leitner (1):
      sctp: allow setting SCTP_SACK_IMMEDIATELY by the application

Martin Roth (1):
      82xx: FCC: Fixing a bug causing to FCC port lock-up (second try)

Michael Buesch (1):
      ssb: Set linux-wireless as MAINTAINERS list

Michael Chan (2):
      bnxt_en: Exclude rx_drop_pkts hw counter from the stack's rx_drop=
ped counter.
      bnxt_en: Fix crash in bnxt_free_tx_skbs() during tx timeout.

Neal Cardwell (1):
      tcp: fix tcp_mark_head_lost to check skb len before fragmenting

Nicolas Schichan (1):
      net: mv643xx_eth: fix packet corruption with TSO and tiny unalign=
ed packets.

Nikolay Aleksandrov (1):
      macvlan: make operstate and carrier more accurate

Oren Givon (3):
      iwlwifi: add new 3168 series devices support
      iwlwifi: add device ID for 8265
      iwlwifi: update support for 3168 series firmware and NVM

Pablo Neira Ayuso (2):
      netfilter: nft_ct: keep counters away from CONFIG_NF_CONNTRACK_LA=
BELS
      netfilter: nf_tables_netdev: fix error path in module initializat=
ion

Paolo Abeni (2):
      ipv6: enforce flowi6_oif usage in ip6_dst_lookup_tail()
      ipv6/udp: use sticky pktinfo egress ifindex on connect()

Parthasarathy Bhuvaragan (1):
      tipc: fix connection abort during subscription cancel

Prashant Sreedharan (1):
      bnxt_en: Ring free response from close path should use completion=
 ring

Richard Weinberger (1):
      net: Fix dependencies for !HAS_IOMEM archs

Russell King (1):
      net: dsa: fix mv88e6xxx switches

Sachin Kulkarni (1):
      mac80211: Requeue work after scan complete for all VIF types.

Sasha Levin (1):
      netfilter: nf_conntrack: use safer way to lock all buckets

Sowmini Varadhan (1):
      sunvnet: Initialize network_header and transport_header in vnet_r=
x_one()

Sudip Mukherjee (3):
      net/irda: bfin_sir: remove duplicate defines
      net: macb: fix build warning
      defxx: fix build warning

Teresa Remmet (1):
      net: phy: smsc: Fix disabling energy detect mode

Thadeu Lima de Souza Cascardo (1):
      sit: set rtnl_link_ops before calling register_netdevice

Thomas Egerer (1):
      ipv4+ipv6: Make INET*_ESP select CRYPTO_ECHAINIV

Ursula Braun (1):
      af_iucv: Validate socket address length in iucv_sock_bind()

Vitaly Kuznetsov (1):
      hv_netvsc: use skb_get_hash() instead of a homegrown implementati=
on

Vivien Didelot (1):
      net: dsa: mv88e6xxx: fix port VLAN maps

WANG Cong (1):
      irda: fix a potential use-after-free in ircomm_param_request

Woojung.Huh@microchip.com (3):
      lan78xx: change to use updated phy-ignore-interrupts
      lan78xx: Add to handle mux control per chip id
      lan78xx: throttle TX path at slower than SuperSpeed USB

Xin Long (4):
      net: change tcp_syn_retries documentation
      sctp: fix the transport dead race check by using atomic_add_unles=
s on refcnt
      sctp: hold transport before we access t->asoc in sctp proc
      sctp: remove the dead field of sctp_transport

Yuchung Cheng (1):
      tcp: avoid cwnd undo after receiving ECN

yankejian (1):
      net: hns: enet specifies a reference to dsaf

 Documentation/devicetree/bindings/net/brcm,bcmgenet.txt           |   =
4 +-
 Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt      |   =
5 +-
 Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt       |   =
7 +--
 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |   =
7 ++-
 Documentation/devicetree/bindings/net/mdio-mux-gpio.txt           |   =
8 ---
 Documentation/devicetree/bindings/net/mdio-mux.txt                |   =
8 ---
 Documentation/devicetree/bindings/net/phy.txt                     |   =
6 ++-
 Documentation/networking/ip-sysctl.txt                            |   =
2 +-
 MAINTAINERS                                                       |   =
2 +-
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi                      |  1=
9 ++++---
 drivers/net/dsa/mv88e6xxx.c                                       |   =
5 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c                  |  1=
2 +++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h                  |   =
1 +
 drivers/net/ethernet/aurora/nb8800.c                              |   =
4 +-
 drivers/net/ethernet/broadcom/Kconfig                             |   =
5 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                         |   =
9 ++--
 drivers/net/ethernet/broadcom/genet/bcmmii.c                      |   =
2 +-
 drivers/net/ethernet/broadcom/tg3.c                               |   =
2 +-
 drivers/net/ethernet/cadence/macb.c                               |   =
2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c                   |   =
4 +-
 drivers/net/ethernet/ezchip/Kconfig                               |   =
1 +
 drivers/net/ethernet/freescale/Makefile                           |   =
3 ++
 drivers/net/ethernet/freescale/fec.h                              |  4=
4 +++++++++++------
 drivers/net/ethernet/freescale/fec_main.c                         | 13=
3 +++++++++++++++++++++++++------------------------
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c                  |   =
2 +-
 drivers/net/ethernet/hisilicon/hns/hnae.c                         |  1=
7 +++----
 drivers/net/ethernet/hisilicon/hns/hnae.h                         |   =
7 ++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c                 |   =
4 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c                |  1=
0 +---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h                |   =
1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c                     |  1=
5 +++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.h                     |   =
2 +-
 drivers/net/ethernet/hp/hp100.c                                   |  1=
8 -------
 drivers/net/ethernet/intel/i40e/i40e_main.c                       |  1=
5 ++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c                       |   =
4 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c                        |   =
4 +-
 drivers/net/ethernet/marvell/mvneta.c                             |  4=
7 +++++++++++-------
 drivers/net/ethernet/mellanox/mlxsw/reg.h                         |  9=
4 +++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c                    | 16=
1 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h                    |   =
2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c          |  8=
5 +++++++++++++++++++-------------
 drivers/net/ethernet/moxa/moxart_ether.c                          |  4=
6 +++++++++++------
 drivers/net/ethernet/moxa/moxart_ether.h                          |   =
4 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c                    |  3=
1 +++++-------
 drivers/net/ethernet/rocker/rocker.c                              |   =
2 +
 drivers/net/ethernet/sun/sunvnet.c                                |  1=
6 ++++--
 drivers/net/ethernet/ti/davinci_cpdma.c                           |  1=
2 ++---
 drivers/net/fddi/defxx.c                                          |   =
8 +--
 drivers/net/geneve.c                                              |   =
4 +-
 drivers/net/hyperv/hyperv_net.h                                   |   =
1 +
 drivers/net/hyperv/netvsc.c                                       |  3=
3 ++++++++-----
 drivers/net/hyperv/netvsc_drv.c                                   |  6=
7 ++-----------------------
 drivers/net/irda/bfin_sir.h                                       |   =
3 --
 drivers/net/macvlan.c                                             |   =
2 +
 drivers/net/phy/Kconfig                                           |   =
1 +
 drivers/net/phy/dp83640.c                                         |  1=
7 +++++++
 drivers/net/phy/phy.c                                             |  4=
6 ++++++++++-------
 drivers/net/phy/smsc.c                                            |  5=
4 ++++++++++++++++----
 drivers/net/ppp/pptp.c                                            |  3=
4 +++++++++----
 drivers/net/usb/lan78xx.c                                         | 13=
2 ++++++++++++++++++++++++++++++++-----------------
 drivers/net/vxlan.c                                               |  2=
5 +++++++---
 drivers/net/wireless/ath/ath9k/eeprom.c                           |  1=
2 ++---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c         |  4=
0 ++++++---------
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c         |   =
1 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c           |   =
5 ++
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h           |   =
1 +
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c                     |  2=
3 +++++++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h                |   =
6 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c                       |  7=
4 ++++++++++++++++++----------
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                       |   =
5 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c                     |   =
4 ++
 drivers/net/wireless/mac80211_hwsim.c                             |   =
5 +-
 drivers/net/wireless/ralink/rt2x00/rt2400pci.c                    |   =
4 +-
 drivers/net/wireless/ralink/rt2x00/rt2500pci.c                    |   =
4 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c                    |   =
4 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c                    |   =
3 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h                       |   =
1 +
 drivers/net/wireless/ralink/rt2x00/rt2x00config.c                 |   =
5 ++
 drivers/net/wireless/ralink/rt2x00/rt2x00mac.c                    |   =
5 --
 drivers/net/wireless/ralink/rt2x00/rt61pci.c                      |   =
4 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c                      |   =
4 +-
 drivers/net/wireless/realtek/rtlwifi/regd.c                       |   =
2 +-
 drivers/net/xen-netfront.c                                        |  1=
5 ++----
 drivers/of/of_mdio.c                                              |  3=
7 +++++++++++++-
 drivers/ptp/ptp_ixp46x.c                                          |   =
7 +--
 drivers/ssb/main.c                                                |   =
7 +--
 fs/compat_ioctl.c                                                 |   =
3 ++
 include/linux/netdevice.h                                         |  1=
1 ++---
 include/net/bluetooth/l2cap.h                                     |   =
6 +++
 include/net/dst_metadata.h                                        |  1=
8 +++++++
 include/net/ip6_route.h                                           |  1=
2 ++++-
 include/net/netfilter/nf_conntrack_core.h                         |   =
8 ++-
 include/net/sctp/structs.h                                        |   =
5 +-
 include/net/sock.h                                                |  1=
2 -----
 include/net/sock_reuseport.h                                      |   =
2 +-
 include/net/tcp.h                                                 |   =
2 +-
 net/bluetooth/6lowpan.c                                           |   =
7 ++-
 net/bluetooth/hci_request.c                                       |  2=
8 +++++++----
 net/bluetooth/l2cap_core.c                                        |  1=
4 +++++-
 net/bluetooth/l2cap_sock.c                                        |  1=
2 ++---
 net/bluetooth/smp.c                                               |  1=
6 ------
 net/bridge/br.c                                                   |   =
3 +-
 net/core/dev.c                                                    |   =
7 ++-
 net/core/sock_reuseport.c                                         |   =
9 +++-
 net/ipv4/Kconfig                                                  |   =
1 +
 net/ipv4/fib_trie.c                                               |   =
7 +--
 net/ipv4/inet_diag.c                                              |  2=
1 +++++---
 net/ipv4/ip_fragment.c                                            |   =
1 +
 net/ipv4/ip_input.c                                               |   =
5 +-
 net/ipv4/ipconfig.c                                               |   =
4 ++
 net/ipv4/netfilter/nf_defrag_ipv4.c                               |   =
2 -
 net/ipv4/tcp.c                                                    |  1=
2 +++--
 net/ipv4/tcp_input.c                                              |  1=
2 ++---
 net/ipv4/tcp_ipv4.c                                               |  1=
3 +++--
 net/ipv4/udp.c                                                    |  3=
2 +++++++-----
 net/ipv6/Kconfig                                                  |   =
1 +
 net/ipv6/datagram.c                                               |   =
3 ++
 net/ipv6/ip6_output.c                                             |   =
6 ++-
 net/ipv6/route.c                                                  |   =
7 ++-
 net/ipv6/sit.c                                                    |   =
4 +-
 net/ipv6/udp.c                                                    |  3=
2 +++++++-----
 net/irda/ircomm/ircomm_param.c                                    |   =
3 +-
 net/iucv/af_iucv.c                                                |   =
3 ++
 net/mac80211/ibss.c                                               |   =
1 -
 net/mac80211/main.c                                               |   =
6 +++
 net/mac80211/mesh.c                                               |  1=
1 -----
 net/mac80211/mesh.h                                               |   =
4 --
 net/mac80211/mlme.c                                               |   =
2 -
 net/mac80211/offchannel.c                                         |  1=
6 +++---
 net/mac80211/scan.c                                               |  2=
0 +++++++-
 net/mac80211/sta_info.c                                           |   =
2 +-
 net/mac80211/status.c                                             |   =
5 ++
 net/mac80211/util.c                                               |  1=
6 ++++--
 net/netfilter/ipset/ip_set_hash_netiface.c                        |   =
4 --
 net/netfilter/nf_conntrack_core.c                                 |  3=
8 ++++++++++----
 net/netfilter/nf_conntrack_helper.c                               |   =
2 +-
 net/netfilter/nf_conntrack_netlink.c                              |   =
2 +-
 net/netfilter/nf_tables_netdev.c                                  |   =
8 +--
 net/netfilter/nfnetlink_cttimeout.c                               |   =
4 +-
 net/netfilter/nft_byteorder.c                                     |   =
6 +--
 net/netfilter/nft_ct.c                                            |   =
2 +-
 net/netfilter/xt_TCPMSS.c                                         |   =
9 +++-
 net/netlink/af_netlink.c                                          |   =
3 +-
 net/rfkill/core.c                                                 |  1=
6 ++----
 net/sched/sch_drr.c                                               |   =
2 +
 net/sctp/input.c                                                  |  1=
7 ++++---
 net/sctp/proc.c                                                   |  1=
2 +++--
 net/sctp/sm_sideeffect.c                                          |  1=
2 -----
 net/sctp/socket.c                                                 |   =
2 +
 net/sctp/transport.c                                              |   =
8 ++-
 net/switchdev/switchdev.c                                         |  1=
5 +++---
 net/tipc/subscr.c                                                 |  1=
1 ++---
 net/unix/af_unix.c                                                |   =
1 +
 net/wireless/reg.c                                                |  4=
5 +++++++++--------
 154 files changed, 1402 insertions(+), 843 deletions(-)
