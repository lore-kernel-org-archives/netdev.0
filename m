From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 14 Dec 2013 23:14:54 -0500 (EST)
Message-ID: <20131214.231454.1031392747120140219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Revert CHECKSUM_COMPLETE optimization in pskb_trim_rcsum(), I can't =
figure
   out why it breaks things.

2) Fix comparison in netfilter ipset's hash_netnet4_data_equal(), it wa=
s
   basically doing "x =3D=3D x", from Dave Jones.

3) Freescale FEC driver was DMA mapping the wrong number of bytes, from=
=09
   Sebastian Siewior.

4) Blackhole and prohibit routes in ipv6 were not doing the right thing
   because their ->input and ->output methods were not being assigned
   correctly.  Now they behave properly like their ipv4 counterparts.
   From Kamala R.

5) Several drivers advertise the NETIF_F_FRAGLIST capability, but reall=
y
   do not support this feature and will send garbage packets if fed
   fraglist SKBs.  From Eric Dumazet.

6) Fix long standing user triggerable BUG_ON over loopback in RDS
   protocol stack, from Venkat Venkatsubra.

7) Several not so common code paths can potentially try to invoke packe=
t
   scheduler actions that might be NULL without checking.  Shore things
   up by either 1) defining a method as mandatory and erroring on
   registration if that method is NULL 2) defininig a method as optiona=
l
   and the registration function hooks up a default implementation when
   NULL is seen.  From Jamal Hadi Salim.

8) Fix fragment detection in xen-natback driver, from Paul Durrant.

9) Kill dangling enter_memory_pressure method in cg_proto ops, from
   Eric W. Biederman.

10) SKBs that traverse namespaces should have their local_df cleared,
    from Hannes Frederic Sowa.

11) IOCB file position is not being updated by macvtap_aio_read() and
    tun_chr_aio_read().  From Zhi Yong Wu.

12) Don't free virtio_net netdev before releasing all of the NAPI
    instances.  From Andrey Vagin.

13) Procfs entry leak in xt_hashlimit, from Sergey Popovich.

14) IPv6 routes that are no cached routes should not count against the
    garbage collection limits.  We had this almost right, but were
    missing handling addrconf generated routes properly.  From Hannes
    Frederic Sowa.

15) fib{4,6}_rule_suppress() have to consider potentially seeing NULL
    route info when they are called, from Stefan Tomanek.

16) TUN and MACVTAP have had truncated packet signalling for some time,
    fix from Jason Wang.

17) Fix use after frrr in __udp4_lib_rcv(), from Eric Dumazet.

18) xen-netback does not interpret the NAPI budget properly for TX work=
,
    fix from Paul Durrant.

Please pull, thanks a lot!

The following changes since commit a45299e72737c528975546a0680cace5d736=
4d27:

  Merge branch 'irq-urgent-for-linus' of git://git.kernel.org/pub/scm/l=
inux/kernel/git/tip/tip (2013-12-02 10:15:39 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to df29df92adda751ac04ca5149d30014b5199db81=
:

  igb: Fix for issue where values could be too high for udelay function=
=2E (2013-12-14 22:59:42 -0500)

----------------------------------------------------------------
Alexander Bondar (1):
      iwlwifi: pcie: stop sending commands to dead firmware

Alexandre Rames (1):
      sfc: Stop/re-start PTP when stopping/starting the datapath.

Andrew Rybchenko (1):
      sfc: RX buffer allocation takes prefix size into account in IP he=
ader alignment

Andrey Vagin (2):
      virtio-net: determine type of bufs correctly
      virtio: delete napi structures from netdev before releasing memor=
y

Arend van Spriel (1):
      brcmfmac: fix uninitialized warning

Ben Hutchings (3):
      sfc: Add length checks to efx_xmit_with_hwtstamp() and efx_ptp_is=
_ptp_tx()
      sfc: Rate-limit log message for PTP packets without a matching ti=
mestamp event
      sfc: Maintain current frequency adjustment when applying a time o=
ffset

Bob Copeland (1):
      Revert "mac80211: allow disable power save in mesh"

Borislav Petkov (1):
      brcmsmac: Fix build dep on LEDS_CLASS

Carolyn Wyborny (1):
      igb: Fix for issue where values could be too high for udelay func=
tion.

Changli Gao (1):
      net: drop_monitor: fix the value of maxattr

Chun-Yeow Yeoh (1):
      mac80211: fix the mesh channel switch support

Daniel Borkmann (1):
      packet: fix send path when running with proto =3D=3D 0

Dave Jones (1):
      netfilter: ipset: fix incorret comparison in hash_netnet4_data_eq=
ual()

David S. Miller (11):
      Revert "net: Handle CHECKSUM_COMPLETE more adequately in pskb_tri=
m_rcsum()."
      Merge branch 'cxgb4'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'net_sched_actions'
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'sfc-3.13' of git://git.kernel.org/.../bwh/sfc
      net: Revert macvtap/tun truncation signalling changes.
      Merge branch 'tipc'
      Merge branch 'sctp'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Revert "8390 : Replace ei_debug with msg_enable/NETIF_MSG_* featu=
re"

Duan Jiong (1):
      ipv6: judge the accept_ra_defrtr before calling rt6_route_rcv

Eliad Peller (1):
      mac80211: fix connection polling

Emmanuel Grumbach (5):
      iwlwifi: pcie: fix interrupt coalescing for 7260 / 3160
      iwlwifi: mvm: BT Coex - don't enable MULTI_PRIO_LUT
      iwlwifi: mvm: BT Coex fix another NULL pointer dereference
      iwlwifi: mvm: don't WARN about unsuccessful time event
      iwlwifi: bump required firmware API version for 3160/7260

Eric Dumazet (4):
      net: do not pretend FRAGLIST support
      udp: ipv4: fix an use after free in __udp4_lib_rcv()
      udp: ipv4: fix potential use after free in udp_v4_early_demux()
      udp: ipv4: must add synchronization in udp_sk_rx_dst_set()

Eric W. Biederman (1):
      tcp_memcontrol: Cleanup/fix cg_proto->memory_pressure handling.

Ezequiel Garcia (1):
      net: mvneta: Fix incorrect DMA unmapping size

=46an Du (1):
      vxlan: release rt when found circular route

=46elix Fietkau (3):
      mac80211: fix crash when using AP VLAN interfaces
      cfg80211: ignore supported rates for nonexistant bands on scan
      ath9k: fix duration calculation for non-aggregated packets

=46lorent Fourcot (1):
      ipv6: do not erase dst address with flow label destination

=46ran=E7ois-Xavier Le Bail (1):
      ipv6: fix third arg of anycast_dst_alloc(), must be bool.

Hannes Frederic Sowa (2):
      net: clear local_df when passing skb between namespaces
      ipv6: don't count addrconf generated routes against gc limit

Hariprasad Shenai (3):
      cxgb4: Much cleaner implementation of is_t4()/is_t5()
      cxgb4vf: added much cleaner implementation of is_t4()
      cxgb4: Add new scheme to update T4/T5 firmware

Ivan Vecera (1):
      forcedeth: run loopback test only on chipsets that support it

Jamal Hadi Salim (5):
      net_sched: Fail if missing mandatory action operation methods
      net_sched: Default action lookup method for actions
      net_sched: Use default action lookup functions
      net_sched: Provide default walker function for actions
      net_sched: Use default action walker methods

Janusz Dziedzic (1):
      mac80211: DFS setup chandef for radar_event correctly

Jason Wang (4):
      tun: unbreak truncated packet signalling
      macvtap: signal truncated packets
      tun: unbreak truncated packet signalling
      macvtap: signal truncated packets

Javier Lopez (1):
      mac80211: fix for mesh beacon update on powersave

Jeff Kirsher (1):
      MAINTAINERS: Update Intel Wired Ethernet LAN Maintainers

Jesse Brandeburg (1):
      i40e: fix null dereference

Jiri Pirko (1):
      br: fix use of ->rx_handler_data in code executed on non-rx_handl=
er path

Jitendra Kalsaria (3):
      qlge: Fix ethtool statistics
      qlge: Allow enable/disable rx/tx vlan acceleration independently
      qlge: Update version to 1.00.00.34

Johannes Berg (7):
      mac80211: fix scheduled scan rtnl deadlock
      nl80211: check nla_put_* return values
      nl80211: fix error path in nl80211_get_key()
      nl80211: check nla_nest_start() return value
      cfg80211: disable 5/10 MHz support for all drivers
      mac80211: don't attempt to reorder multicast frames
      iwlwifi: mvm: check sta_id/drain values in debugfs

John W. Linville (5):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi=
-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jon Paul Maloy (1):
      tipc: correct the order of stopping services at rmmod

Jouni Malinen (2):
      mac80211_hwsim: Fix radiotap header for ACK frames
      mac80211_hwsim: Fix bcn_en_iter to use atomic iteration

Kamala R (1):
      IPv6: Fixed support for blackhole and prohibit routes

Karl Beldan (3):
      mac80211: minstrel_ht: fix rates selection
      mac80211: use capped prob when computing throughputs
      mac80211: set hw initial idle state

Laurence Evans (1):
      sfc: PTP: Moderate log message on event queue overflow

Luciano Coelho (2):
      iwlwifi: mvm: set seqno also when no keys are set
      iwlwifi: mvm: use a cast to calculate the last seqno from the nex=
t one

Matthew Whitehead (1):
      8390 : Replace ei_debug with msg_enable/NETIF_MSG_* feature

Maxime Ripard (1):
      net: allwinner: emac: Add missing free_irq

Michael Dalton (1):
      virtio-net: free bufs correctly on invalid packet length

Michal Kalderon (1):
      bnx2x: avoid null pointer dereference when enabling SR-IOV

Michal Nazarewicz (2):
      net: wireless: ath9k: avoid possible NULL pointer dereference
      net: wireless: wcn36xx: fix potential NULL pointer dereference

Mugunthan V N (2):
      drivers: net: cpsw: fix dt probe for one port ethernet
      drivers: net: cpsw: fix for cpsw crash when build as modules

Nat Gurumoorthy (1):
      tg3: Initialize REG_BASE_ADDR at PCI config offset 120 to 0

Neil Horman (1):
      sctp: properly latch and use autoclose value from sock to associa=
tion

Nikolay Aleksandrov (1):
      bonding: fix packets_per_slave showing

Oren Givon (1):
      iwlwifi: add new HW - 7265 series

Pablo Neira Ayuso (1):
      netfilter: nf_tables: fix missing rules flushing per table

Paul Durrant (6):
      xen-netback: clear vif->task on disconnect
      xen-netback: fix fragment detection in checksum setup
      xen-netback: make sure skb linear area covers checksum field
      xen-netback: napi: fix abuse of budget
      xen-netback: napi: don't prematurely request a tx event
      xen-netback: fix gso_prefix check

Philippe De Muyter (1):
      net:fec: remove duplicate lines in comment about errata ERR006358

Rafael J. Wysocki (1):
      PCI / tg3: Give up chip reset and carrier loss handling if PCI de=
vice is not present

Robert Stonehouse (2):
      sfc: Refactor efx_mcdi_poll() by introducing efx_mcdi_poll_once()
      sfc: Poll for MCDI completion once before timeout occurs

Sasha Levin (1):
      net: unix: allow set_peek_off to fail

Sebastian Siewior (2):
      net: fec_main: dma_map() only the length of the skb
      net: make neigh_priv_len in struct net_device 16bit instead of 8b=
it

Sergei Shtylyov (1):
      micrel: add support for KSZ8041RNLI

Sergey Popovich (1):
      netfilter: xt_hashlimit: fix proc entry leak in netns destroy pat=
h

Simon Wunderlich (3):
      cfg80211: fix ibss wext chandef creation
      cfg80211: disable CSA for all drivers
      mac80211: check csa wiphy flag in ibss before switching

Somnath Kotur (2):
      be2net: Fix Lancer error recovery to distinguish FW download
      be2net: Free/delete pmacs (in be_clear()) only if they exist

Srikanth Thokala (2):
      net: emaclite: Remove unnecessary code that enables/disables inte=
rrupts on PONG buffers
      net: emaclite: add barriers to support Xilinx Zynq platform

Stefan Tomanek (1):
      inet: fix NULL pointer Oops in fib(6)_rule_suppress

Sujith Manoharan (2):
      ath9k: Fix QuickDrop usage
      ath9k: Fix XLNA bias strength

Tony Lindgren (2):
      net: davinci_emac: Fix platform data handling and make usable for=
 am3517
      net: smc91x: Fix device tree based configuration so it's usable

Ujjal Roy (1):
      mwifiex: fix memory leak issue for ibss join

Venkat Venkatsubra (1):
      rds: prevent BUG_ON triggered on congestion update to loopback

Wei Yang (1):
      net/mlx4_core: destroy workqueue when driver fails to register

Yang Yingliang (3):
      net: sched: tbf: fix the calculation of max_size
      net: sched: htb: fix the calculation of quantum
      sch_tbf: use do_div() for 64-bit divide

Ying Xue (1):
      tipc: protect handler_enabled variable with qitem_lock spin lock

Zhi Yong Wu (2):
      macvtap: update file current position
      tun: update file current position

dingtianhong (1):
      bonding: add arp_ip_target checks when install the module

wangweidong (4):
      sctp: disable max_burst when the max_burst is 0
      sctp: check the rto_min and rto_max in setsockopt
      sctp: add check rto_min and rto_max in sysctl
      sctp: fix up a spacing

 Documentation/devicetree/bindings/net/davinci_emac.txt   |   2 +-
 Documentation/devicetree/bindings/net/smsc-lan91c111.txt |   4 +
 Documentation/networking/packet_mmap.txt                 |  10 ++
 MAINTAINERS                                              |   2 -
 drivers/net/bonding/bond_main.c                          |   6 +-
 drivers/net/bonding/bond_sysfs.c                         |   4 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c              |   5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c        |   5 +
 drivers/net/ethernet/broadcom/tg3.c                      |  29 ++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h               |  82 +++++++=
++------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          | 278 +++++++=
+++++++++++++++++++-------------------------
 drivers/net/ethernet/chelsio/cxgb4/sge.c                 |  12 +--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c               | 230 +++++++=
+++++++++++++++++++----------------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h             |  14 +++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h            |   7 +-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h           |   1 -
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c      |  15 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c               |   2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h       |  24 +++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c           |   4 +-
 drivers/net/ethernet/emulex/benet/be_hw.h                |   3 +
 drivers/net/ethernet/emulex/benet/be_main.c              |  41 +++++--=
-
 drivers/net/ethernet/freescale/fec_main.c                |  13 +--
 drivers/net/ethernet/ibm/ehea/ehea_main.c                |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c              |   3 +
 drivers/net/ethernet/intel/igb/e1000_phy.c               |   5 +-
 drivers/net/ethernet/marvell/mvneta.c                    |   4 +-
 drivers/net/ethernet/mellanox/mlx4/main.c                |   2 +
 drivers/net/ethernet/nvidia/forcedeth.c                  |   8 +-
 drivers/net/ethernet/qlogic/qlge/qlge.h                  |   2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c          |   4 +
 drivers/net/ethernet/qlogic/qlge/qlge_main.c             |   8 --
 drivers/net/ethernet/sfc/efx.c                           |   8 +-
 drivers/net/ethernet/sfc/mcdi.c                          |  39 ++++++-=
-
 drivers/net/ethernet/sfc/net_driver.h                    |   3 +
 drivers/net/ethernet/sfc/nic.h                           |   2 +
 drivers/net/ethernet/sfc/ptp.c                           |  66 +++++++=
+++--
 drivers/net/ethernet/sfc/rx.c                            |   6 +-
 drivers/net/ethernet/smsc/smc91x.c                       |  45 +++++++=
--
 drivers/net/ethernet/tehuti/tehuti.c                     |   1 -
 drivers/net/ethernet/ti/cpsw.c                           |  19 +++-
 drivers/net/ethernet/ti/davinci_emac.c                   |  26 ++++-
 drivers/net/ethernet/xilinx/ll_temac_main.c              |   2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c        |   2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c            |  51 +++----=
---
 drivers/net/macvtap.c                                    |  13 ++-
 drivers/net/phy/micrel.c                                 |  15 +++
 drivers/net/tun.c                                        |  18 ++--
 drivers/net/virtio_net.c                                 |  17 ++--
 drivers/net/vxlan.c                                      |   2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c           |  22 ++--
 drivers/net/wireless/ath/ath9k/hw.c                      |   7 +-
 drivers/net/wireless/ath/ath9k/xmit.c                    |   4 +
 drivers/net/wireless/ath/wcn36xx/smd.c                   |  19 ++--
 drivers/net/wireless/brcm80211/Kconfig                   |   2 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c   |   2 +
 drivers/net/wireless/iwlwifi/iwl-7000.c                  |  29 +++++-
 drivers/net/wireless/iwlwifi/iwl-config.h                |   5 +
 drivers/net/wireless/iwlwifi/iwl-csr.h                   |   5 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c               |   6 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c                    |   5 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c               |   4 +
 drivers/net/wireless/iwlwifi/mvm/time-event.c            |   7 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c                  |  21 ++++
 drivers/net/wireless/iwlwifi/pcie/internal.h             |   8 ++
 drivers/net/wireless/iwlwifi/pcie/rx.c                   |   7 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c                |   3 -
 drivers/net/wireless/iwlwifi/pcie/tx.c                   |   6 +-
 drivers/net/wireless/mac80211_hwsim.c                    |  16 ++-
 drivers/net/wireless/mwifiex/sta_ioctl.c                 |   4 +-
 drivers/net/xen-netback/interface.c                      |  20 ++--
 drivers/net/xen-netback/netback.c                        | 266 +++++++=
++++++++++++++++++++---------------------
 drivers/pci/pci.c                                        |   8 ++
 include/linux/ipv6.h                                     |   1 +
 include/linux/micrel_phy.h                               |   2 +
 include/linux/net.h                                      |   2 +-
 include/linux/netdevice.h                                |   2 +-
 include/linux/pci.h                                      |   1 +
 include/linux/skbuff.h                                   |  39 ++++---=
-
 include/net/ipv6.h                                       |   3 +-
 include/net/sctp/structs.h                               |   6 --
 include/net/sock.h                                       |   6 +-
 net/bridge/br_private.h                                  |  10 ++
 net/bridge/br_stp_bpdu.c                                 |   2 +-
 net/core/drop_monitor.c                                  |   1 -
 net/core/skbuff.c                                        |   1 +
 net/core/sock.c                                          |   2 +-
 net/dccp/ipv6.c                                          |   1 -
 net/ipv4/fib_rules.c                                     |   5 +-
 net/ipv4/tcp_memcontrol.c                                |   7 --
 net/ipv4/udp.c                                           |  47 +++++--=
--
 net/ipv6/addrconf.c                                      |   2 +-
 net/ipv6/datagram.c                                      |   1 -
 net/ipv6/fib6_rules.c                                    |   6 +-
 net/ipv6/ndisc.c                                         |   3 +
 net/ipv6/raw.c                                           |   1 -
 net/ipv6/route.c                                         |  30 +++---
 net/ipv6/tcp_ipv6.c                                      |   1 -
 net/ipv6/udp.c                                           |   1 -
 net/l2tp/l2tp_ip6.c                                      |   1 -
 net/mac80211/cfg.c                                       |  15 ++-
 net/mac80211/ibss.c                                      |   4 +
 net/mac80211/ieee80211_i.h                               |   1 +
 net/mac80211/iface.c                                     |   1 -
 net/mac80211/main.c                                      |   3 +
 net/mac80211/mesh.c                                      |  20 ++--
 net/mac80211/mlme.c                                      |   2 +
 net/mac80211/rc80211_minstrel_ht.c                       |   7 +-
 net/mac80211/rx.c                                        |   3 +-
 net/mac80211/scan.c                                      |   2 +-
 net/mac80211/spectmgmt.c                                 |   2 +
 net/mac80211/util.c                                      |  11 +-
 net/netfilter/ipset/ip_set_hash_netnet.c                 |   2 +-
 net/netfilter/nf_tables_api.c                            |  46 ++++++-=
--
 net/netfilter/xt_hashlimit.c                             |  25 ++---
 net/packet/af_packet.c                                   |  65 +++++++=
-----
 net/rds/ib_send.c                                        |   5 +-
 net/sched/act_api.c                                      |  26 ++---
 net/sched/act_csum.c                                     |   2 -
 net/sched/act_gact.c                                     |   2 -
 net/sched/act_ipt.c                                      |   4 -
 net/sched/act_mirred.c                                   |   2 -
 net/sched/act_nat.c                                      |   2 -
 net/sched/act_pedit.c                                    |   2 -
 net/sched/act_police.c                                   |   1 -
 net/sched/act_simple.c                                   |   1 -
 net/sched/act_skbedit.c                                  |   1 -
 net/sched/sch_htb.c                                      |  20 ++--
 net/sched/sch_tbf.c                                      | 117 +++++++=
++++++---------
 net/sctp/associola.c                                     |   5 +-
 net/sctp/output.c                                        |   3 +-
 net/sctp/sm_statefuns.c                                  |  12 +--
 net/sctp/socket.c                                        |  36 +++++--
 net/sctp/sysctl.c                                        |  76 +++++++=
+++++--
 net/sctp/transport.c                                     |   2 +-
 net/tipc/core.c                                          |   7 +-
 net/tipc/handler.c                                       |  11 +-
 net/unix/af_unix.c                                       |   8 +-
 net/wireless/core.c                                      |   9 ++
 net/wireless/ibss.c                                      |  18 ++--
 net/wireless/nl80211.c                                   |  60 ++++++-=
----
 141 files changed, 1551 insertions(+), 916 deletions(-)
