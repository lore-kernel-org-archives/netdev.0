From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 22 Oct 2013 16:36:32 -0400 (EDT)
Message-ID: <20131022.163632.253476567162545817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sorry I let so much accumulate, I was in Buffalo and wanted a few
things to cook in my tree for a while before sending to you.  Anyways,
it's a lot of little things as usual at this stage in the game.

1) Make bonding MAINTAINERS entry reflect reality, from Andy Gospodarek=
=2E

2) Fix accidental sock_put() on timewait mini sockets, from Eric
   Dumazet.

3) Fix crashes in l2tp due to mis-handling of ipv4 mapped ipv6 addresse=
s,
   from Fran=E7ois CACHEREUL.

4) Fix heap overflow in __audit_sockaddr(), from the eagle eyed Dan
   Carpenter.

5) tcp_shifted_skb() doesn't take handle FINs properly, from Eric
   Dumazet.

6) SFC driver bug fixes from Ben Hutchings.

7) Fix TX packet scheduling wedge after channel change in ath9k driver,
   from Felix Fietkau.

8) Fix user after free in BPF JIT code, from Alexei Starovoitov.

9) Source address selection test is reversed in __ip_route_output_key()=
,
   fix from Jiri Benc.

10) VLAN and CAN layer mis-size netlink attributes, from Marc
    Kleine-Budde.

11) Fix permission checks in sysctls to use current_euid() instead of
    current_uid().  From Eric W. Biederman.

12) IPSEC policies can go away while a timer is still pending for them,
    add appropriate ref-counting to fix, from Steffen Klassert.

13) Fix mis-programming of FDR and RMCR registers on R8A7740 sh_eth
    chips, from Nguyen Hong Ky and Simon Horman.

14) MLX4 forgets to DMA unmap pages on RX, fix from Amir Vadai.

15) IPV6 GRE tunnel MTU upper limit is miscalculated, from Oussama
    Ghorbel.

16) Fix typo in fq_change(), we were assigning "initial quantum" to
    "quantum".  From Eric Dumazet.

17) Set a more appropriate sk_pacing_rate for non-TCP sockets, otherwis=
e
    FQ packet scheduler does not pace those flows properly.  Also from
    Eric Dumazet.

18) rtlwifi miscalculates packet pointers, from Mark Cave-Ayland.

19) l2tp_xmit_skb() can be called from process context, not just
    softirq context, so we must always make sure to BH disable
    around it.  From Eric Dumazet.

20) On qdisc reset, we forget to purge the RB tree of SKBs in netem
    packet scheduler.  From Stephen Hemminger.

21) Fix info leak in farsync WAN driver ioctl() handler, from Dan
    Carpenter and Salva Peir=F3.

22) Fix PHY reset and other issues in dm9000 driver, from Nikita
    Kiryanov and Michael Abbott.

23) When hardware can do SCTP crc32 checksums, we accidently don't
    disable the csum offload when IPSEC transformations have been
    applied.  From Fan Du and Vlad Yasevich.

24) Tail loss probing in TCP leaves the socket in the wrong congestion
    avoidance state.  From Yuchung Cheng.

25) In CPSW driver, enable NAPI before interrupts are turned on, from
    Markus Pargmann.

26) Integer underflow and dual-assignment in YAM hamradio driver, from
    Dan Carpenter.

27) If we are going to mangle a packet in tcp_set_skb_tso_segs() we mus=
t
    unclone it.  This fixes various hard to track down crashes in drive=
rs
    where the SKBs ->gso_segs was changing right from underneath the
    driver during TX queueing.  From Eric Dumazet.

28) Fix the handling of VLAN IDs, and in particular the special IDs 0 a=
nd
    4095, in the bridging layer.  From Toshiaki Makita.

29) Another info leak, this time in wanxl WAN driver, from Salva Peir=F3=
=2E

30) Fix race in socket credential passing, from Daniel Borkmann.

31) WHen NETLABEL is disabled, we don't validate CIPSO packets properly=
,
    from Seif Mazareeb.

32) Fix identification of fragmented frames in ipv4/ipv6 UDP
    Fragmentation Offload output paths, from Jiri Pirko.

33) Virtual Function fixes in bnx2x driver from Yuval Mintz and Ariel
    Elior.

34) When we removed the explicit neighbour pointer from ipv6 routes
    a slight regression was introduced for users such as IPVS, xt_TEE,
    and raw sockets.  We mix up the users requested destination address
    with the routes assigned nexthop/gateway.  From Julian Anastasov
    and Simon Horman.

35) Fix stack overruns in rt6_probe(), the issue is that can end up
    doing two full packet xmit paths at the same time when emitting
    neighbour discovery messages.  From Hannes Frederic Sowa.

36) davinci_emac driver doesn't handle IFF_ALLMULTI correctly, from
    Mariusz Ceier.

37) Make sure to set TCP sk_pacing_rate after the first legitimate
    RTT sample, from Neal Cardwell.

38) Wrong netlink attribute passed to xfrm_replay_verify_len(), from
    Steffen Klassert.

Please pull, thanks a lot!

The following changes since commit c31eeaced22ce8bd61268a3c595d542bb38c=
0a4f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-1=
0-01 12:58:48 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to f11a5bc148a313ad37c361c87c9aff2331a8b149=
:

  ax88179_178a: Add VID:DID for Samsung USB Ethernet Adapter (2013-10-2=
2 15:43:43 -0400)

----------------------------------------------------------------
Alan Ott (5):
      6lowpan: Only make 6lowpan links to IEEE802154 devices
      6lowpan: Sync default hardware address of lowpan links to their w=
pan
      mrf24j40: Move INIT_COMPLETION() to before packet transmission
      mrf24j40: Use threaded IRQ handler
      mrf24j40: Use level-triggered interrupts

Alexander Bondar (1):
      iwlwifi: mvm: Disable uAPSD for D3 image

Alexandre Belloni (1):
      mac802154: correct a typo in ieee802154_alloc_device() prototype

Alexei Starovoitov (1):
      net: fix unsafe set_memory_rw from softirq

Amir Vadai (2):
      net/mlx4_en: Rename name of mlx4_en_rx_alloc members
      net/mlx4_en: Fix pages never dma unmapped on rx

Amitkumar Karwar (1):
      mwifiex: fix SDIO interrupt lost issue

Andi Kleen (2):
      igb: Avoid uninitialized advertised variable in eee_set_cur
      tcp: Always set options to 0 before calling tcp_established_optio=
ns

Andy Gospodarek (1):
      bonding: update MAINTAINERS

Ariel Elior (3):
      bnx2x: Unlock VF-PF channel on MAC/VLAN config error
      bnx2x: Fix config when SR-IOV and iSCSI are enabled
      bnx2x: Lock DMAE when used by statistic flow

Avinash Patil (2):
      mwifiex: inform cfg80211 about disconnect if device is removed
      mwifiex: inform cfg80211 about disconnect for P2P client interfac=
e

Ben Hutchings (1):
      sfc: Only bind to EF10 functions with the LinkCtrl and Trusted fl=
ags

Bruno Randolf (1):
      cfg80211: fix warning when using WEXT for IBSS

Christophe Gouault (1):
      vti: get rid of nf mark rule in prerouting

Chun-Yeow Yeoh (1):
      mac80211: fix the setting of extended supported rate IE

Claudiu Manoil (3):
      gianfar: Enable eTSEC-A002 erratum w/a for all parts
      gianfar: Use mpc85xx support for errata detection
      gianfar: Enable eTSEC-20 erratum w/a for P2020 Rev1

Dan Carpenter (3):
      net: heap overflow in __audit_sockaddr()
      yam: integer underflow in yam_ioctl()
      yam: remove a no-op in yam_ioctl()

Daniel Borkmann (1):
      net: unix: inherit SOCK_PASS{CRED, SEC} flags from socket to fix =
race

David S. Miller (20):
      Merge branch 'connector'
      Merge branch 'calxedaxgmac'
      Merge branch 'mv643xx'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch '6lowpan'
      Merge branch 'mrf24j40'
      l2tp: Fix build warning with ipv6 disabled.
      Merge branch 'mlx4'
      Merge branch 'sfc-3.12' of git://git.kernel.org/.../bwh/sfc
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'gianfar'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'dm9000'
      Merge branch 'sctp_csum'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'bridge_pvid'
      Merge branch 'ufo_fixes'
      Merge branch 'bnx2x'
      Merge branch 'rt6i_gateway'

David Vrabel (1):
      xen-netback: transition to CLOSED when removing a VIF

Dmitry Kravkov (2):
      bnx2x: Fix Coalescing configuration
      bnx2x: Don't pretend during register dump

Edward Cree (3):
      sfc: Fix internal indices of ethtool stats for EF10
      sfc: Refactor EF10 stat mask code to allow for more conditional s=
tats
      sfc: Add PM and RXDP drop counters to ethtool stats

Emmanuel Grumbach (6):
      iwlwifi: pcie: don't reset the TX queue counter
      iwlwifi: don't WARN on host commands sent when firmware is dead
      iwlwifi: pcie: add SKUs for 6000, 6005 and 6235 series
      iwlwifi: mvm: call ieee80211_scan_completed when needed
      mac80211: correctly close cancelled scans
      cfg80211: don't add p2p device while in RFKILL

Enrico Mioso (1):
      net: qmi_wwan: Olivetti Olicard 200 support

Eric Dumazet (8):
      net: do not call sock_put() on TIMEWAIT sockets
      tcp: do not forget FIN in tcp_shifted_skb()
      pkt_sched: fq: fix typo for initial_quantum
      pkt_sched: fq: fix non TCP flows pacing
      l2tp: must disable bh before calling l2tp_xmit_skb()
      bnx2x: record rx queue for LRO packets
      tcp: must unclone packets before mangling them
      tcp: remove the sk_can_gso() check from tcp_set_skb_tso_segs()

Eric W. Biederman (1):
      net: Update the sysctl permissions handler to test effective uid/=
gid

=46abio Estevam (1):
      net: secure_seq: Fix warning when CONFIG_IPV6 and CONFIG_INET are=
 not selected

=46an Du (2):
      xfrm: Guard IPsec anti replay window against replay bitmap
      sctp: Use software crc32 checksum when xfrm transform will happen=
=2E

=46elix Fietkau (5):
      mac80211: drop spoofed packets in ad-hoc mode
      mac80211: use sta_info_get_bss() for nl80211 tx and client probin=
g
      mac80211: update sta->last_rx on acked tx frames
      ath9k: fix powersave response handling for BA session packets
      ath9k: fix tx queue scheduling after channel changes

=46ran=E7ois Cachereul (1):
      l2tp: fix kernel panic when using IPv4-mapped IPv6 addresses

=46reddy Xin (2):
      ax88179_178a: Correct the RX error definition in RX header
      ax88179_178a: Add VID:DID for Samsung USB Ethernet Adapter

Hannes Frederic Sowa (1):
      ipv6: probe routes asynchronous in rt6_probe

Himanshu Madhani (1):
      qlcnic: Validate Tx queue only for 82xx adapters.

Jason Wang (2):
      virtio-net: don't respond to cpu hotplug notifier if we're not re=
ady
      virtio-net: refill only when device is up during setting queues

Jiri Benc (1):
      ipv4: fix ineffective source address selection

Jiri Pirko (3):
      udp6: respect IPV6_DONTFRAG sockopt in case there are pending fra=
mes
      ip6_output: do skb ufo init for peeked non ufo skb as well
      ip_output: do skb ufo init for peeked non ufo skb as well

Johannes Berg (4):
      cfg80211: fix sysfs registration race
      iwlwifi: pcie: fix merge damage
      wireless: radiotap: fix parsing buffer overrun
      mac80211: fix crash if bitrate calculation goes wrong

John W. Linville (7):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jon Cooper (1):
      sfc: Add rmb() between reading stats and generation count to ensu=
re consistency

Jouni Malinen (1):
      mac80211: Run deferred scan if last roc_list item is not started

Julian Anastasov (3):
      ipv6: always prefer rt6i_gateway if present
      ipv6: fill rt6i_gateway with nexthop address
      netfilter: nf_conntrack: fix rt6i_gateway checks for H.323 helper

Linus L=FCssing (1):
      Revert "bridge: only expire the mdb entry when query is received"

Luciano Coelho (1):
      cfg80211: use the correct macro to check for active monitor suppo=
rt

Marc Kleine-Budde (5):
      can: dev: fix nlmsg size calculation in can_get_size()
      net: vlan: fix nlmsg size calculation in vlan_get_size()
      can: flexcan: flexcan_chip_start: fix regression, mark one MB for=
 TX and abort pending TX
      can: flexcan: fix mx28 detection by rearanging OF match table
      can: at91-can: fix device to driver data mapping for platform dev=
ices

Mariusz Ceier (1):
      davinci_emac.c: Fix IFF_ALLMULTI setup

Mark Cave-Ayland (1):
      rtlwifi: rtl8192cu: Fix error in pointer arithmetic

Markus Pargmann (3):
      net: ethernet: cpsw: Search childs for slave nodes
      net/ethernet: cpsw: DT read bool dual_emac
      net/ethernet: cpsw: Bugfix interrupts before enabling napi

Mathias Krause (5):
      proc connector: fix info leaks
      connector: use nlmsg_len() to check message length
      connector: use 'size' everywhere in cn_netlink_send()
      connector - documentation: simplify netlink message length assign=
ment
      unix_diag: fix info leak

Matthew Slattery (1):
      sfc: Add definitions for new stats counters and capability flag

Matthias Schiffer (1):
      batman-adv: set up network coding packet handlers during module i=
nit

Matti Gottlieb (1):
      iwlwifi: pcie: add new SKUs for 7000 & 3160 NIC series

Merav Sicron (1):
      bnx2x: Set NETIF_F_HIGHDMA unconditionally

Michael Abbott (1):
      dm9000: Implement full reset of DM9000 network device

Michael S. Tsirkin (2):
      netif_set_xps_queue: make cpu mask const
      tun: don't look at current when non-blocking

Mugunthan V N (1):
      drivers: net: cpsw: fix kernel warn during iperf test with interr=
upt pacing

Neal Cardwell (1):
      tcp: initialize passive-side sk_pacing_rate after 3WHS

Nguyen Hong Ky (1):
      net: sh_eth: Fix RX packets errors on R8A7740

Nikita Kiryanov (3):
      dm9000: during init reset phy only for dm9000b
      dm9000: take phy out of reset during init
      dm9000: report the correct LPA

Oussama Ghorbel (3):
      ipv6: Allow the MTU of ipip6 tunnel to be set below 1280
      ipv6: Fix the upper MTU limit in GRE tunnel
      ipv6: Initialize ip6_tnl.hlen in gre tunnel even if no route is f=
ound

Rob Herring (3):
      net: calxedaxgmac: fix clearing of old filter addresses
      net: calxedaxgmac: add uc and mc filter addresses in promiscuous =
mode
      net: calxedaxgmac: determine number of address filters at runtime

Salva Peir=F3 (2):
      farsync: fix info leak in ioctl
      wanxl: fix info leak in ioctl

Sebastian Hesselbarth (3):
      net: mv643xx_eth: update statistics timer from timer context only
      net: mv643xx_eth: fix orphaned statistics timer crash
      net: mv643xx_eth: fix missing device_node for port devices

Seif Mazareeb (1):
      net: fix cipso packet validation when !NETLABEL

Simon Horman (1):
      net: sh_eth: Correct fix for RX packet errors on R8A7740

Solomon Peachy (1):
      wireless: cw1200: acquire hwbus lock around cw1200_irq_handler() =
call.

Stanislaw Gruszka (1):
      Revert "rt2x00pci: Use PCI MSIs whenever possible"

Steffen Klassert (5):
      xfrm: Fix replay size checking on async events
      xfrm: Decode sessions with output interface.
      ipsec: Don't update the pmtu on ICMPV6_DEST_UNREACH
      xfrm: Add refcount handling to queued policies
      xfrm: check for a vaild skb in xfrm_policy_queue_process

Thomas Egerer (1):
      xfrm: Fix aevent generation for each received packet

Toshiaki Makita (4):
      bridge: Don't use VID 0 and 4095 in vlan filtering
      bridge: Apply the PVID to priority-tagged frames
      bridge: Fix the way the PVID is referenced
      bridge: Fix updating FDB entries when the PVID is applied

Vasundhara Volam (1):
      be2net: pass if_id for v1 and V2 versions of TX_CREATE cmd

Vlad Yasevich (4):
      bridge: update mdb expiration timer upon reports.
      net: dst: provide accessor function to dst->xfrm
      sctp: Perform software checksum if packet has to be fragmented.
      bridge: Correctly clamp MAX forward_delay when enabling STP

Wei Yongjun (3):
      moxa: fix the error handling in moxart_mac_probe()
      qlcnic: add missing destroy_workqueue() on error path in qlcnic_p=
robe()
      usbnet: fix error return code in usbnet_probe()

Will Deacon (1):
      net: smc91x: dont't use SMC_outw for fixing up halfword-aligned d=
ata

Yuchung Cheng (1):
      tcp: fix incorrect ca_state in tail loss probe

Yuval Mintz (3):
      bnx2x: Fix Maximum CoS estimation for VFs
      bnx2x: Prevent an illegal pointer dereference during panic
      bnx2x: Prevent null pointer dereference on error flow

stephen hemminger (3):
      tc: export tc_defact.h to userspace
      netem: update backlog after drop
      netem: free skb's in tree on reset

 Documentation/connector/ucon.c                      |   2 +-
 MAINTAINERS                                         |   1 +
 arch/arm/net/bpf_jit_32.c                           |   1 +
 arch/powerpc/net/bpf_jit_comp.c                     |   1 +
 arch/s390/net/bpf_jit_comp.c                        |   4 +-
 arch/sparc/net/bpf_jit_comp.c                       |   1 +
 arch/x86/net/bpf_jit_comp.c                         |  18 ++-
 drivers/connector/cn_proc.c                         |  18 +++
 drivers/connector/connector.c                       |   9 +-
 drivers/net/can/at91_can.c                          |   4 +-
 drivers/net/can/dev.c                               |  10 +-
 drivers/net/can/flexcan.c                           |  14 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         |  15 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |  40 +-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h    |  38 ++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 388 ++++++++++++=
++++++++++++++++++++---------------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c   |  29 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c   |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c    |   2 +-
 drivers/net/ethernet/calxeda/xgmac.c                |  23 ++--
 drivers/net/ethernet/davicom/dm9000.c               |  56 ++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.c         |   3 +-
 drivers/net/ethernet/freescale/gianfar.c            |  38 ++++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c        |   2 +
 drivers/net/ethernet/marvell/mv643xx_eth.c          |   7 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c          |  41 ++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h        |   4 +-
 drivers/net/ethernet/moxa/moxart_ether.c            |  22 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    |  13 +-
 drivers/net/ethernet/renesas/sh_eth.c               |   4 +
 drivers/net/ethernet/sfc/ef10.c                     |  87 ++++++++++--=
--
 drivers/net/ethernet/sfc/mcdi.c                     |  18 ++-
 drivers/net/ethernet/sfc/mcdi_pcol.h                |  56 ++++++++-
 drivers/net/ethernet/sfc/nic.c                      |   9 +-
 drivers/net/ethernet/sfc/nic.h                      |  12 ++
 drivers/net/ethernet/smsc/smc91x.h                  |   6 +-
 drivers/net/ethernet/ti/cpsw.c                      |  19 ++-
 drivers/net/ethernet/ti/davinci_emac.c              |   3 +-
 drivers/net/hamradio/yam.c                          |   1 -
 drivers/net/ieee802154/mrf24j40.c                   |  31 ++---
 drivers/net/tun.c                                   |   8 +-
 drivers/net/usb/ax88179_178a.c                      |  23 +++-
 drivers/net/usb/qmi_wwan.c                          |   1 +
 drivers/net/usb/usbnet.c                            |   4 +-
 drivers/net/virtio_net.c                            |  14 ++-
 drivers/net/wan/farsync.c                           |   1 +
 drivers/net/wan/wanxl.c                             |   1 +
 drivers/net/wireless/ath/ath9k/main.c               |  23 ++--
 drivers/net/wireless/ath/ath9k/xmit.c               |   9 +-
 drivers/net/wireless/cw1200/cw1200_spi.c            |   2 +
 drivers/net/wireless/iwlwifi/iwl-6000.c             |   6 +
 drivers/net/wireless/iwlwifi/iwl-config.h           |   1 +
 drivers/net/wireless/iwlwifi/iwl-trans.h            |   6 +-
 drivers/net/wireless/iwlwifi/mvm/power.c            |   5 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c             |  12 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c             |  42 +++++++
 drivers/net/wireless/iwlwifi/pcie/trans.c           |   8 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c              |   2 +
 drivers/net/wireless/mwifiex/join.c                 |  10 +-
 drivers/net/wireless/mwifiex/main.c                 |   6 +-
 drivers/net/wireless/mwifiex/sta_event.c            |   3 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c             |   9 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c        |   3 +-
 drivers/net/xen-netback/xenbus.c                    |   4 +
 include/linux/filter.h                              |  15 ++-
 include/linux/netdevice.h                           |   5 +-
 include/linux/yam.h                                 |   2 +-
 include/net/cipso_ipv4.h                            |   6 +-
 include/net/dst.h                                   |  12 ++
 include/net/ip6_route.h                             |   6 +-
 include/net/mac802154.h                             |   2 +-
 include/net/sock.h                                  |   6 +-
 include/uapi/linux/tc_act/Kbuild                    |   1 +
 include/{ =3D> uapi}/linux/tc_act/tc_defact.h         |   2 +-
 net/8021q/vlan_netlink.c                            |   2 +-
 net/batman-adv/main.c                               |   5 +-
 net/batman-adv/network-coding.c                     |  28 +++--
 net/batman-adv/network-coding.h                     |  14 ++-
 net/bridge/br_fdb.c                                 |   4 +-
 net/bridge/br_mdb.c                                 |   2 +-
 net/bridge/br_multicast.c                           |  38 ++++--
 net/bridge/br_netlink.c                             |   2 +-
 net/bridge/br_private.h                             |   5 +-
 net/bridge/br_stp_if.c                              |   2 +-
 net/bridge/br_vlan.c                                | 125 ++++++++++--=
-------
 net/compat.c                                        |   2 +
 net/core/dev.c                                      |   3 +-
 net/core/filter.c                                   |   8 +-
 net/core/secure_seq.c                               |   2 +
 net/core/sock.c                                     |   1 +
 net/ieee802154/6lowpan.c                            |   5 +
 net/ipv4/inet_hashtables.c                          |   2 +-
 net/ipv4/ip_output.c                                |  13 +-
 net/ipv4/ip_vti.c                                   |  14 ++-
 net/ipv4/route.c                                    |   2 +-
 net/ipv4/tcp_input.c                                |   9 +-
 net/ipv4/tcp_output.c                               |  14 ++-
 net/ipv4/xfrm4_policy.c                             |   1 +
 net/ipv6/ah6.c                                      |   3 +-
 net/ipv6/esp6.c                                     |   3 +-
 net/ipv6/inet6_hashtables.c                         |   2 +-
 net/ipv6/ip6_gre.c                                  |   6 +-
 net/ipv6/ip6_output.c                               |  29 +++--
 net/ipv6/ip6_tunnel.c                               |  12 +-
 net/ipv6/ipcomp6.c                                  |   3 +-
 net/ipv6/route.c                                    |  46 +++++--
 net/ipv6/udp.c                                      |   5 +-
 net/ipv6/xfrm6_policy.c                             |   1 +
 net/key/af_key.c                                    |   3 +-
 net/l2tp/l2tp_core.c                                |  36 ++++--
 net/l2tp/l2tp_core.h                                |   3 +
 net/l2tp/l2tp_ppp.c                                 |   4 +
 net/mac80211/cfg.c                                  |   2 +-
 net/mac80211/ieee80211_i.h                          |   3 +
 net/mac80211/offchannel.c                           |   2 +
 net/mac80211/rx.c                                   |   3 +
 net/mac80211/scan.c                                 |  19 +++
 net/mac80211/status.c                               |   3 +
 net/mac80211/tx.c                                   |   3 +-
 net/mac80211/util.c                                 |   9 +-
 net/netfilter/nf_conntrack_h323_main.c              |   4 +-
 net/sched/sch_fq.c                                  |  22 ++--
 net/sched/sch_netem.c                               |  17 +++
 net/sctp/output.c                                   |   3 +-
 net/socket.c                                        |  24 +++-
 net/sysctl_net.c                                    |   4 +-
 net/unix/af_unix.c                                  |  10 ++
 net/unix/diag.c                                     |   1 +
 net/wireless/core.c                                 |  23 ++--
 net/wireless/core.h                                 |   3 +
 net/wireless/ibss.c                                 |   3 +
 net/wireless/nl80211.c                              |   4 +-
 net/wireless/radiotap.c                             |   7 +-
 net/xfrm/xfrm_policy.c                              |  28 +++--
 net/xfrm/xfrm_replay.c                              |  54 +++++----
 net/xfrm/xfrm_user.c                                |   5 +-
 138 files changed, 1313 insertions(+), 717 deletions(-)
 rename include/{ =3D> uapi}/linux/tc_act/tc_defact.h (75%)
