From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 03 Mar 2015 15:35:15 -0500 (EST)
Message-ID: <20150303.153515.2218952298028191168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) If an IPVS tunnel is created with a mixed-family destination address=
,
   it cannot be removed.  Fix from Alexey Andriyanov.

2) Fix module refcount underflow in netfilter's nft_compat, from Pablo
   Neira Ayuso.

3) Generic statistics infrastructure can reference variables sitting on
   a released function stack, therefore use dynamic allocation always.
   Fix from Ignacy Gaw=EAdzki.

4) skb_copy_bits() return value test is inverted in ip_check_defrag().

5) Fix network namespace exit in openvswitch, we have to release all of
   the per-net vports.  From Pravin B Shelar.

6) Fix signedness bug in CAIF's cfpkt_iterate(), from Dan Carpenter.

7) Fix rhashtable grow/shrink behavior, only expand during inserts
   and shrink during deletes.  From Daniel Borkmann.

8) Netdevice names with semicolons should never be allowed, because
   they serve as a separator.  From Matthew Thode.

9) Use {,__}set_current_state() where appropriate, from Fabian Frederic=
k.

10) Revert byte queue limits support in r8169 driver, it's causing
    regressions we can't figure out.

11) tcp_should_expand_sndbuf() erroneously uses tp->packets_out to meas=
ure
    packets in flight, properly use tcp_packets_in_flight() instead.  F=
rom
    Neal Cardwell.

12) Fix accidental removal of support for bluetooth in CSR based Intel
    wireless cards.  From Marcel Holtmann.

13) We accidently added a behavioral change between native and compat
    tasks, wrt. testing the MSG_CMSG_COMPAT bit.  Just ignore it if
    the user happened to set it in a native binary as that was always
    the behavior we had.  From Catalin Marinas.

14) Check genlmsg_unicast() return valud in hwsim netlink tx frame
    handling, from Bob Copeland.

15) Fix stale ->radar_required setting in mac80211 that can prevent
    starting new scans, from Eliad Peller.

16) Fix memory leak in nl80211 monitor, from Johannes Berg.

17) Fix race in TX index handling in xen-netback, from David Vrabel.

18) Don't enable interrupts in amx-xgbe driver until all software et al=
=2E
    state is ready for the interrupt handler to run.  From Thomas
    Lendacky.

19) Add missing netlink_ns_capable() checks to rtnl_newlink(), from
    Eric W. Biederman.

20) The amount of header space needed in macvtap was not calculated
    properly, fix it otherwise we splat past the beginning of the
    packet.  From Eric Dumazet.

21) Fix bcmgenet TCP TX perf regression, from Jaedon Shin.

22) Don't raw initialize or mod timers, use setup_timer() and mod_timer=
()
    instead.  From Vaishali Thakkar.

23) Fix software maintained statistics in bcmgenet and systemport drive=
rs,
    from Florian Fainelli.

24) DMA descriptor updates in sh_eth need proper memory barriers, from
    Ben Hutchings.

25) Don't do UDP Fragmentation Offload on RAW sockets, from Michal
    Kubecek.

26) Openvswitch's non-masked set actions aren't constructed properly
    into netlink messages, fix from Joe Stringer.

Please pull, thanks a lot!

The following changes since commit 5c2770079fb9b8c5bfb7113d9e76de66e77a=
0e24:

  Merge tag 'mfd-for-linus-3.20' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lee/mfd (2015-02-18 09:05:48 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to f4f8e73850589008095b1da3c8c17cf68bd1c62a=
:

  openvswitch: Fix serialization of non-masked set actions. (2015-03-03=
 14:38:57 -0500)

----------------------------------------------------------------
Akeem G Abodunrin (1):
      i40e: Don't check for Tx hang when PF down

Alexander Drozdov (3):
      ipv4: ip_check_defrag should correctly check return value of skb_=
copy_bits
      af_packet: allow packets defragmentation not only for hash fanout=
 type
      af_packet: don't pass empty blocks for PACKET_V3

Alexey Andriyanov (1):
      ipvs: fix inability to remove a mixed-family RS

Alexey Khoroshilov (1):
      i40e: Fix memory leak at failure path in i40e_dbg_command_write()

Andy Gospodarek (1):
      MAINTAINERS: update my email address

Anish Bhatt (1):
      cxgb4: Fix incorrect 'c' suffix to %pI4, use %pISc instead

Anjali Singhai (3):
      i40e: Fix TSO with more than 8 frags per segment issue
      i40e: Fix the case where per TC queue count was higher than queue=
s enabled
      i40evf: TCP/IPv6 over Vxlan Tx checksum offload fix

Anton Blanchard (1):
      ehea: Register memory hotplug, reboot and crash hooks on adapter =
probe

Arnd Bergmann (3):
      net: smc91x: improve neponset hack
      net/appletalk: LTPC needs virt_to_bus
      net: smc91x: use run-time configuration on all ARM machines

Arvid Brodin (1):
      net/hsr: Fix NULL pointer dereference and refcnt bugs when deleti=
ng a HSR interface.

Ben Hutchings (4):
      sh_eth: Ensure proper ordering of descriptor active bit write/rea=
d
      sh_eth: Fix RX recovery on R-Car in case of RX ring underrun
      Revert "sh_eth: Enable Rx descriptor word 0 shift for r8a7790"
      sh_eth: Really fix padding of short frames on TX

Ben Shelton (1):
      usb: plusb: Add support for National Instruments host-to-host cab=
le

Bob Copeland (1):
      mac80211_hwsim: fix error handling in tx_frame_nl

Catalin Marinas (1):
      net: compat: Ignore MSG_CMSG_COMPAT in compat_sys_{send, recv}msg

Dan Carpenter (4):
      caif: fix a signedness bug in cfpkt_iterate()
      rocker: add a check for NULL in rocker_probe_ports()
      rocker: silence shift wrapping warning
      niu: fix error handling in niu_class_to_ethflow()

Daniel Borkmann (6):
      rhashtable: don't allocate ht structure on stack in test_rht_init
      rhashtable: don't test for shrink on insert, expansion on delete
      rhashtable: better high order allocation attempts
      rhashtable: allow to unload test module
      rhashtable: unconditionally grow when max_shift is not specified
      rhashtable: remove indirection for grow/shrink decision functions

David S. Miller (9):
      Merge git://git.kernel.org/.../pablo/nf
      r8169: Revert BQL and xmit_more support.
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'rhashtable'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge tag 'mac80211-for-davem-2015-02-27' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'bcmgenet_systemport_stats'
      Merge branch 'mlx4'
      Merge branch 'sh_eth'

David Vrabel (1):
      xen-netback: release pending index before pushing Tx responses

Derrick Pallas (1):
      ethernet/ixp4xx: prevent allmulti from clobbering promisc

Eliad Peller (1):
      mac80211: clear sdata->radar_required

Eric Dumazet (7):
      netfilter: xt_socket: fix a stack corruption bug
      sock: sock_dequeue_err_skb() needs hard irq safety
      rhashtable: ensure cache line alignment on bucket_table
      net: pktgen: disable xmit_clone on virtual devices
      rhashtable: use cond_resched()
      macvtap: make sure neighbour code can push ethernet header
      net: do not use rcu in rtnl_dump_ifinfo()

Eric W. Biederman (2):
      net: Verify permission to dest_net in newlink
      net: Verify permission to link_net in newlink

=46abian Frederick (4):
      mISDN: replace current->state by set_current_state()
      hso: replace current->state by __set_current_state()
      wan: cosa: replace current->state by set_current_state()
      irda: replace current->state by set_current_state()

=46lorian Fainelli (3):
      net: dsa: bcm_sf2: fix 64-bits register reads
      net: bcmgenet: fix software maintained statistics
      net: systemport: fix software maintained statistics

=46lorian Westphal (4):
      netfilter: xt_recent: don't reject rule if new hitcount exceeds t=
able max
      rxrpc: terminate retrans loop when sending of skb fails
      rxrpc: don't multiply with HZ twice
      net: bridge: add compile-time assert for cb struct size

Geert Uytterhoeven (2):
      net: Initialize all members in skb_gro_remcsum_init()
      sh_eth: Fix lost MAC address on kexec

George McCollister (1):
      drivers: net: cpsw: Set SECURE for dual_emac ucast

Grygorii Strashko (2):
      net: davinci_mdio: add hibernation callbacks
      net: ti: cpsw: add hibernation callbacks

Guenter Roeck (2):
      net: phy: Fix verification of EEE support in phy_init_eee
      gianfar: Reduce logging noise seen due to phy polling if link is =
down

Hariprasad Shenai (1):
      cxgb4: Fix PCI-E Memory window interface for big-endian systems

Ido Shamay (1):
      net/mlx4_en: Disbale GRO for incoming loopback/selftest packets

Ignacy Gaw=EAdzki (2):
      gen_stats.c: Duplicate xstats buffer for later use
      ematch: Fix auto-loading of ematch modules.

Jaedon Shin (1):
      net: bcmgenet: fix throughtput regression

Jamal Hadi Salim (1):
      net: sched: export tc_connmark.h so it is uapi accessible

Jason Abele (1):
      cfg80211: fix n_reg_rules to match world_regdom

Jesse Brandeburg (1):
      i40e: fix race in hang check

Jiri Pirko (1):
      team: fix possible null pointer dereference in team_handle_frame

Jiri Slaby (1):
      mac80211/minstrel: fix !x!=3D0 confusion

Joe Stringer (1):
      openvswitch: Fix serialization of non-masked set actions.

Johannes Berg (1):
      nl80211: fix memory leak in monitor flags parsing

Jouni Malinen (1):
      mac80211: Send EAPOL frames at lowest rate

Junjie Mao (1):
      cfg80211: calls nl80211_exit on error

Lendacky, Thomas (1):
      amd-xgbe: Request IRQs only after driver is fully setup

Luca Ceresoli (1):
      net: asix: add support for the Sitecom LN-028 USB adapter

Mahesh Bandewar (1):
      ipvlan: Fix text that talks about ip util support

Marcel Holtmann (1):
      Bluetooth: btusb: Fix issue with CSR based Intel Wireless control=
lers

Marcelo Leitner (1):
      ipv6: addrconf: validate new MTU before applying it

Matthew Thode (1):
      net: reject creation of netdev names with colons

Michael S. Tsirkin (2):
      vhost: cleanup iterator update logic
      vhost: drop hard-coded num_buffers size

Michal Kube=E8ek (1):
      udp: only allow UFO for packets from SOCK_DGRAM sockets

Mitch A Williams (1):
      i40e: stop flow director on shutdown

Neal Cardwell (1):
      tcp: fix tcp_should_expand_sndbuf() to use tcp_packets_in_flight(=
)

Or Gerlitz (1):
      net/mlx4_core: Fix wrong mask and error flow for the update-qp co=
mmand

Pablo Neira Ayuso (1):
      netfilter: nft_compat: fix module refcount underflow

Parikh, Neerav (2):
      i40e: Fix the Tx ring qset handle when DCB reconfigures
      i40e: Issue a PF reset if Tx queue disable timeout

Pravin B Shelar (1):
      openvswitch: Fix net exit.

Rami Rosen (1):
      ethtool: Add hw-switch-offload to netdev_features_strings.

Rasmus Villemoes (1):
      decnet: Fix obvious o/0 typo

Samuel Tan (1):
      nl80211: use loop index as type for net detect frequency results

Sasha Levin (2):
      rhashtable: initialize all rhashtable walker members
      rtnetlink: avoid 0 sized arrays

Shannon Nelson (4):
      i40e: fix shift precedence issue
      i40e: disconnect irqs on shutdown
      i40e: catch NVM write semaphore timeout and retry
      i40e: check pointers before use

Sujith Sankar (1):
      enic: do notify_check before returning credits

Thomas Falcon (1):
      ibmveth: Add function to enable live MAC address changes

Tom Lendacky (1):
      amd-xgbe-phy: PHY KX/KR mode differences

Vaishali Thakkar (5):
      net: smc91c92_cs: Use setup_timer and mod_timer
      net: 8390: pcnet_cs: Use setup_timer and mod_timer
      net: 8390: axnet_cs: Use setup_timer and mod_timer
      net: stmmac: Use setup_timer and mod_timer
      net: pasemi: Use setup_timer and mod_timer

Vlastimil Setka (2):
      altera_tse: Correct typo in obtaining tx_fifo_depth from devicetr=
ee
      altera_tse: Fixes in NAPI and interrupt handling paths

Yannick Guerrini (3):
      r8169: Fix trivial typo in rtl_check_firmware
      qlcnic: Fix trivial typo in comment
      netxen_nic: Fix trivial typos in comments

 Documentation/devicetree/bindings/net/amd-xgbe-phy.txt |   4 ++
 MAINTAINERS                                            |   2 +-
 arch/arm/mach-msm/board-halibut.c                      |   8 ++-
 arch/arm/mach-msm/board-qsd8x50.c                      |   8 ++-
 arch/arm/mach-pxa/idp.c                                |   5 ++
 arch/arm/mach-pxa/lpd270.c                             |   8 ++-
 arch/arm/mach-realview/core.c                          |   7 +++
 arch/arm/mach-realview/realview_eb.c                   |   2 +-
 arch/arm/mach-sa1100/neponset.c                        |   6 +++
 arch/arm/mach-sa1100/pleb.c                            |   7 +++
 drivers/bluetooth/btusb.c                              |   1 +
 drivers/isdn/hardware/mISDN/hfcpci.c                   |   2 +-
 drivers/net/Kconfig                                    |   2 +-
 drivers/net/appletalk/Kconfig                          |   2 +-
 drivers/net/dsa/bcm_sf2.h                              |   2 +-
 drivers/net/ethernet/8390/axnet_cs.c                   |   7 +--
 drivers/net/ethernet/8390/pcnet_cs.c                   |   7 +--
 drivers/net/ethernet/altera/altera_tse_main.c          |  47 ++++++++-=
-------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c               | 175 +++++++++=
++++++++++++++++++++++----------------------------
 drivers/net/ethernet/broadcom/bcmsysport.c             |   7 +--
 drivers/net/ethernet/broadcom/bcmsysport.h             |   2 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c         | 122 +++++++++=
+++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h         |   2 +
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c          |  57 +++++++++=
+----------
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h          |   6 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h             |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c             |  54 +++++++++=
++++++----
 drivers/net/ethernet/cisco/enic/enic_main.c            |   4 +-
 drivers/net/ethernet/freescale/gianfar.c               |   4 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c              | 246 +++++++++=
++++++++++++++++++++++++++++++++++++++---------------------------------=
---
 drivers/net/ethernet/ibm/ibmveth.c                     |  24 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_common.c          |   7 +--
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c          |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c            |  44 +++++++++=
++----
 drivers/net/ethernet/intel/i40e/i40e_nvm.c             |  35 +++++++++=
+++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c            | 119 +++++++++=
++++++++++++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h            |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c          | 143 +++++++++=
++++++++++++++++++++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h          |   1 +
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c       |   8 ++-
 drivers/net/ethernet/mellanox/mlx4/qp.c                |   1 -
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c  |   9 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c               |   8 ++-
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h        |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h            |   2 +-
 drivers/net/ethernet/realtek/r8169.c                   |  32 +++------=
--
 drivers/net/ethernet/renesas/sh_eth.c                  |  18 +++++--
 drivers/net/ethernet/rocker/rocker.c                   |   6 ++-
 drivers/net/ethernet/smsc/smc91c92_cs.c                |   7 +--
 drivers/net/ethernet/smsc/smc91x.c                     |   9 +++-
 drivers/net/ethernet/smsc/smc91x.h                     | 114 ++-------=
------------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c      |  10 ++--
 drivers/net/ethernet/sun/niu.c                         |   6 +--
 drivers/net/ethernet/ti/cpsw.c                         |   9 ++--
 drivers/net/ethernet/ti/davinci_mdio.c                 |   5 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c               |   2 +-
 drivers/net/macvtap.c                                  |   7 ++-
 drivers/net/phy/amd-xgbe-phy.c                         |  82 +++++++++=
++++++++++++++++++-
 drivers/net/phy/phy.c                                  |  23 ++++++--
 drivers/net/team/team.c                                |   4 +-
 drivers/net/usb/Kconfig                                |   1 +
 drivers/net/usb/asix_devices.c                         |   4 ++
 drivers/net/usb/hso.c                                  |   2 +-
 drivers/net/usb/plusb.c                                |   5 ++
 drivers/net/wan/cosa.c                                 |  12 ++---
 drivers/net/wireless/mac80211_hwsim.c                  |   5 +-
 drivers/net/xen-netback/netback.c                      |  29 +++++++--=
-
 drivers/vhost/net.c                                    |  25 +++++----
 include/linux/mlx4/qp.h                                |   2 +-
 include/linux/netdevice.h                              |   1 +
 include/linux/rhashtable.h                             |  22 ++------
 include/net/caif/cfpkt.h                               |   2 +-
 include/uapi/linux/tc_act/Kbuild                       |   1 +
 lib/rhashtable.c                                       |  62 +++++++++=
+-----------
 lib/test_rhashtable.c                                  |  11 ++--
 net/bridge/br.c                                        |   2 +
 net/caif/cffrml.c                                      |   2 +-
 net/caif/cfpkt_skbuff.c                                |   6 +--
 net/compat.c                                           |   9 ----
 net/core/dev.c                                         |   2 +-
 net/core/ethtool.c                                     |   1 +
 net/core/gen_stats.c                                   |  15 +++++-
 net/core/pktgen.c                                      |   3 ++
 net/core/rtnetlink.c                                   |  15 ++++--
 net/core/skbuff.c                                      |   5 +-
 net/decnet/dn_route.c                                  |   2 +-
 net/hsr/hsr_device.c                                   |   3 ++
 net/hsr/hsr_main.c                                     |   4 ++
 net/hsr/hsr_slave.c                                    |  10 ++--
 net/ipv4/ip_fragment.c                                 |   2 +-
 net/ipv4/ip_output.c                                   |   3 +-
 net/ipv4/tcp_input.c                                   |   2 +-
 net/ipv6/addrconf.c                                    |  17 +++++-
 net/ipv6/ip6_output.c                                  |   3 +-
 net/irda/ircomm/ircomm_tty.c                           |   2 +-
 net/irda/irnet/irnet_ppp.c                             |   4 +-
 net/mac80211/chan.c                                    |   5 ++
 net/mac80211/rc80211_minstrel.c                        |   2 +-
 net/mac80211/tx.c                                      |   1 +
 net/netfilter/ipvs/ip_vs_ctl.c                         |   2 +-
 net/netfilter/nft_compat.c                             |  12 ++++-
 net/netfilter/nft_hash.c                               |   2 -
 net/netfilter/xt_recent.c                              |  11 ++--
 net/netfilter/xt_socket.c                              |  21 ++++----
 net/netlink/af_netlink.c                               |   2 -
 net/openvswitch/datapath.c                             |  45 +++++++++=
++++++-
 net/openvswitch/flow_netlink.c                         |   8 ++-
 net/openvswitch/vport.h                                |   2 +
 net/packet/af_packet.c                                 |  20 ++++---
 net/rxrpc/ar-ack.c                                     |   9 ++--
 net/sched/ematch.c                                     |   1 +
 net/tipc/socket.c                                      |   2 -
 net/wireless/core.c                                    |   1 +
 net/wireless/nl80211.c                                 |  12 ++---
 net/wireless/reg.c                                     |   2 +-
 116 files changed, 1273 insertions(+), 737 deletions(-)
