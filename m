From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 17 Dec 2015 16:43:59 -0500 (EST)
Message-ID: <20151217.164359.310820482612009148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix uninitialized variable warnings in nfnetlink_queue, a lot of peo=
ple
   reported this... From Arnd Bergmann.

2) Don't init mutex twice in i40e driver, from Jesse Brandeburg.

3) Fix spurious EBUSY in rhashtable, from Herbert Xu.

4) Missing DMA unmaps in mvpp2 driver, from Marcin Wojtas.

5) Fix race with work structure access in pppoe driver causing
   corruptions, from Guillaume Nault.

6) Fix OOPS due to sh_eth_rx() not checking whether netdev_alloc_skb()
   actually succeeded or not, from Sergei Shtylyov.

7) Don't lose flags when settifn IFA_F_OPTIMISTIC in ipv6 code, from
   Bj=F8rn Mork.

8) VXLAN_HD_RCO defined incorrectly, fix from Jiri Benc.

9) Fix clock source used for cookies in SCTP, from Marcelo Ricardo Leit=
ner.

10) aurora driver needs HAS_DMA dependency, from Geert Uytterhoeven.

11) ndo_fill_metadata_dst op of vxlan has to handle ipv6 tunneling prop=
erly
    as well, from Jiri Benc.

12) Handle request sockets properly in xfrm layer, from Eric Dumazet.

13) Double stats update in ipv6 geneve transmit path, fix from Pravin
    B Shelar.

14) sk->sk_policy[] needs RCU protection, and as a result
    xfrm_policy_destroy() needs to free policies using an RCU grace
    period, from Eric Dumazet.

15) SCTP needs to clone ipv6 tx options in order to avoid use after
    free, from Eric Dumazet.

16) Missing kbuild export if ila.h, from Stephen Hemminger.

17) Missing mdiobus_alloc() return value checking in mdio-mux.c, from
    Tobias Klauser.

18) Validate protocol value range in ->create() methods, from Hannes
    Frederic Sowa.

19) Fix early socket demux races that result in illegal dst reuse,
    from Eric Dumazet.

20) Validate socket address length in pptp code, from WANG Cong.

21) skb_reorder_vlan_header() uses incorrect offset and can corrupt
    packets, from Vlad Yasevich.

22) Fix memory leaks in nl80211 registry code, from Ola Olsson.

23) Timeout loop count handing fixes in mISDN, xgbe, qlge, sfc, and
    qlcnic.  From Dan Carpenter.

24) msg.msg_iocb needs to be cleared in recvfrom() otherwise, for
    example, AF_ALG will interpret it as an async call.  From
    Tadeusz Struk.

25) inetpeer_set_addr_v4 forgets to initialize the 'vif' field, from
    Eric Dumazet.

26) rhashtable enforces the minimum table size not early enough,
    breaking how we calculate the per-cpu lock allocations.  From
    Herbert Xu.

27) Fix FCC port lockup in 82xx driver, from Martin Roth.

28) FOU sockets need to be freed using RCU, from Hannes Frederic Sowa.

29) Fix out-of-bounds access in __skb_complete_tx_timestamp() and
    sock_setsockopt() wrt. timestamp handling.  From WANG Cong.

Please pull, thanks a lot!

The following changes since commit 071f5d105a0ae93aeb02197c4ee3557e8cc5=
7a21:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-1=
2-03 16:02:46 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to ac5cc977991d2dce85fc734a6c71ddb33f6fe3c1=
:

  net: check both type and procotol for tcp sockets (2015-12-17 15:46:3=
2 -0500)

----------------------------------------------------------------
Alan Cox (1):
      ser_gigaset: turn nonsense checks into WARN_ON

Alexander Duyck (1):
      ixgbe: Reset interface after enabling SR-IOV

Andrew Lunn (1):
      phy: micrel: Fix finding PHY properties in MAC node.

Andrzej Hajda (1):
      net/mlx4_core: fix handling return value of mlx4_slave_convert_po=
rt

Andy Shevchenko (2):
      net:hns: annotate IO address space properly
      net:hns: print MAC with %pM

Ariel Elior (1):
      qed: Fix BAR size split for some servers

Arnd Bergmann (3):
      netfilter: nfnetlink_queue: avoid harmless unnitialized variable =
warnings
      net: fsl: avoid 64-bit warning on pq_mdio
      net: ezchip: fix address space confusion in nps_enet.c

Bert Kenward (1):
      sfc: only use RSS filters if we're using RSS

Bj=F8rn Mork (2):
      ipv6: keep existing flags when setting IFA_F_OPTIMISTIC
      net: cdc_mbim: add "NDP to end" quirk for Huawei E3372

Chen-Yu Tsai (1):
      stmmac: dwmac-sunxi: Call exit cleanup function in probe error pa=
th

Dan Carpenter (5):
      mISDN: fix a loop count
      amd-xgbe: fix a couple timeout loops
      qlge: fix a timeout loop in ql_change_rx_buffers()
      sfc: fix a timeout loop
      qlcnic: fix a timeout loop

David Ahern (1):
      net: Flush local routes when device changes vrf association

David S. Miller (13):
      Merge branch 'mvpp2-fixes'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue
      Merge branch 'sctp-timestamp-fixes'
      Revert "rhashtable: Use __vmalloc with GFP_ATOMIC for table alloc=
ation"
      Merge branch 'qed-fixes'
      Merge branch 'vxlan-ipv6-metadata-dst'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'bnxt_en-fixes'
      Merge branch 'mpls-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'ser_gigaset-platform-device-dealloc'
      bluetooth: Validate socket address length in sco_sock_bind().
      Merge tag 'mac80211-for-davem-2015-12-15' of git://git.kernel.org=
/.../jberg/mac80211

Eric Dumazet (9):
      ipv6: sctp: fix lockdep splat in sctp_v6_get_dst()
      xfrm: take care of request sockets
      xfrm: add rcu grace period in xfrm_policy_destroy()
      xfrm: add rcu protection to sk->sk_policy[]
      ipv6: sctp: clone options to avoid use after free
      net: fix IP early demux races
      net_sched: make qdisc_tree_decrease_qlen() work for non mq
      inet: tcp: fix inetpeer_set_addr_v4()
      tcp: restore fastopen with no data in SYN packet

Eyal Shapira (1):
      mac80211: handle width changes from opmode notification IE in bea=
con

=46elix Fietkau (1):
      net: remove unnecessary semicolon in netdev_alloc_pcpu_stats()

Geert Uytterhoeven (1):
      ethernet: aurora: AURORA_NB8800 should depend on HAS_DMA

Giuseppe CAVALLARO (1):
      stmmac: fix resource management when resume

Guillaume Nault (1):
      pppoe: fix memory corruption in padt work structure

Hamish Martin (1):
      gianfar: Don't enable RX Filer if not supported

Hannes Frederic Sowa (4):
      net: add validation for the socket syscall protocol argument
      ipv6: automatically enable stable privacy mode if stable_secret s=
et
      net: fix warnings in 'make htmldocs' by moving macro definition o=
ut of field declaration
      fou: clean up socket with kfree_rcu

Herbert Xu (4):
      rhashtable: Prevent spurious EBUSY errors on insertion
      rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
      rhashtable: Enforce minimum size on initial hash table
      rhashtable: Fix walker list corruption

Iyappan Subramanian (1):
      drivers: net: xgene: fix Tx flow control

Jeff Kirsher (2):
      e100.txt: Cleanup license info in kernel doc
      MAINTAINERS: Update Intel Wired LAN reviewers

Jesse Brandeburg (1):
      i40e/i40evf: avoid mutex re-init

Jiri Benc (4):
      vxlan: fix incorrect RCO bit in VXLAN header
      vxlan: move IPv6 outpute route calculation to a function
      vxlan: support ndo_fill_metadata_dst also for IPv6
      vxlan: interpret IP headers for ECN correctly

Joe Stringer (2):
      openvswitch: Fix helper reference leak
      openvswitch: Respect conntrack zone even if invalid

Johannes Berg (4):
      rfkill: copy the name into the rfkill struct
      mac80211: run scan completed work on reconfig failure
      mac80211: reprogram in interface order
      mac80211: suppress unchanged "limiting TX power" messages

Kazuya Mizuguchi (1):
      ravb: Add disable 10base

Marcelo Ricardo Leitner (3):
      sctp: use the same clock as if sock source timestamps were on
      sctp: update the netstamp_needed counter when copying sockets
      sctp: also copy sk_tsflags when copying the socket

Marcin Wojtas (3):
      net: mvpp2: fix missing DMA region unmap in egress processing
      net: mvpp2: fix buffers' DMA handling on RX path
      net: mvpp2: fix refilling BM pools in RX path

Marek Lindner (1):
      batman-adv: fix erroneous client entry duplicate detection

Martin Roth (1):
      82xx: FCC: Fixing a bug causing to FCC port lock-up

Michael Chan (4):
      bnxt_en: Fix bitmap declaration to work on 32-bit arches.
      bnxt_en: Change bp->state to bitmap.
      bnxt_en: Don't cancel sp_task from bnxt_close_nic().
      bnxt_en: Implement missing tx timeout reset logic.

Nicolas Dichtel (1):
      gre6: allow to update all parameters via rtnl

Nikolay Borisov (1):
      netfilter: nfnetlink_queue: Unregister pernet subsys in case of i=
nit failure

Ola Olsson (3):
      nl80211: fix a few memory leaks in reg.c
      nl80211: Fix potential memory leak in nl80211_set_wowlan
      nl80211: Fix potential memory leak in nl80211_connect

Pablo Neira Ayuso (3):
      netfilter: nfnetlink: avoid recurrent netns lookups in call_batch
      netfilter: nfnetlink: fix splat due to incorrect socket memory ac=
counting in skbuff clones
      netfilter: nf_dup: add missing dependencies with NF_CONNTRACK

Paolo Abeni (1):
      openvswitch: fix trivial comment typo

Pavel Fedin (1):
      net: thunderx: Correctly distinguish between VF and LMAC count

Pavel Machek (1):
      atl1c: Improve driver not to do order 4 GFP_ATOMIC allocation

Peter Wu (1):
      r8152: fix lockup when runtime PM is enabled

Pravin B Shelar (1):
      geneve: Fix IPv6 xmit stats update.

Rainer Weikusat (1):
      af_unix: Revert 'lock_interruptible' in stream receive code

Robert Shearman (5):
      mpls: fix sending of local encapped packets
      mpls: validate L2 via address length
      mpls: don't dump RTA_VIA attribute if not specified
      mpls: fix out-of-bounds access when via address not specified
      mpls: make via address optional for multipath routes

Sergei Shtylyov (6):
      sh_eth: fix kernel oops in skb_put()
      ravb: fix RX queue #1 frame error counter name
      MAINTAINERS: add myself as Renesas Ethernet drivers reviewer
      sh_eth: uninline sh_eth_{write|read}()
      sh_eth: fix TX buffer byte-swapping
      sh_eth: fix descriptor access endianness

Simon Wunderlich (2):
      batman-adv: fix speedy join for DAT cache replies
      batman-adv: avoid keeping false temporary entry

Stefan Wahren (1):
      net: qca_spi: fix transmit queue timeout handling

Sudarsana Kalluru (1):
      qed: Correct slowpath interrupt scheme

Sven Eckelmann (1):
      batman-adv: Fix invalid stack access in batadv_dat_select_candida=
tes

Tilman Schmidt (3):
      ser_gigaset: fix up NULL checks
      ser_gigaset: fix deallocation of platform device structure
      ser_gigaset: remove unnecessary kfree() calls from release method

Tobias Klauser (1):
      net: phy: mdio-mux: Check return value of mdiobus_alloc()

Tomer Tayar (2):
      qed: Fix corner case for chain in-between pages
      qed: fix handling of concurrent ramrods.

Vlad Yasevich (1):
      skbuff: Fix offset error in skb_reorder_vlan_header

WANG Cong (2):
      pptp: verify sockaddr_len in pptp_bind() and pptp_connect()
      net: check both type and procotol for tcp sockets

Xin Long (1):
      netfilter: nf_tables: use reverse traversal commit_list in nf_tab=
les_abort

lucien (3):
      sctp: hold the chunks only after the chunk is enqueued in outq
      sctp: only drop the reference on the datamsg after sending a msg
      sctp: start t5 timer only when peer rwnd is 0 and local state is =
SHUTDOWN_PENDING

stephen hemminger (1):
      uapi: export ila.h

tadeusz.struk@intel.com (1):
      net: fix uninitialized variable issue

 Documentation/networking/e100.txt                     |  14 ----------=
-
 MAINTAINERS                                           |   9 ++++++-
 drivers/isdn/gigaset/ser-gigaset.c                    |  23 +++++++++-=
--------
 drivers/isdn/hardware/mISDN/mISDNipac.c               |   7 +++---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c              |   4 +--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c      |  38 ++++++++++=
+++++++------------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h      |   4 +--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c       |   7 +++---
 drivers/net/ethernet/aurora/Kconfig                   |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.c             |  46 ++++++++++=
++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h             |   6 ++---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c       |   2 +-
 drivers/net/ethernet/cavium/thunder/nic_main.c        |  39 ++++++++++=
++++---------------
 drivers/net/ethernet/ezchip/nps_enet.c                |  30 +++++++---=
-------------
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c      |   2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c          |   2 +-
 drivers/net/ethernet/freescale/gianfar.c              |   8 +++---
 drivers/net/ethernet/freescale/gianfar.h              |   1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    |  49 ++++++++++=
+--------------------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h     |  11 +++++----
 drivers/net/ethernet/intel/i40e/i40e_adminq.c         |   6 -----
 drivers/net/ethernet/intel/i40e/i40e_main.c           |  11 ++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c       |   6 -----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c       |  10 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |   3 +++
 drivers/net/ethernet/marvell/mvpp2.c                  |  52 ++++++++++=
++++++++++++++---------------
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |   5 ++--
 drivers/net/ethernet/qlogic/qed/qed.h                 |   3 +++
 drivers/net/ethernet/qlogic/qed/qed_dev.c             |  53 ++++++++++=
++++++++++++++----------------
 drivers/net/ethernet/qlogic/qed/qed_int.c             |  33 ++++++++++=
++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_int.h             |  15 ++++++++--=
--
 drivers/net/ethernet/qlogic/qed/qed_main.c            |  56 ++++++++++=
++++----------------------------
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h        |   4 +++
 drivers/net/ethernet/qlogic/qed/qed_sp.h              |   8 ++++--
 drivers/net/ethernet/qlogic/qed/qed_spq.c             |  63 ++++++++++=
+++++++++++++++++++++++++------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c |   3 ++-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |   5 ++--
 drivers/net/ethernet/qualcomm/qca_spi.c               |   5 ++--
 drivers/net/ethernet/renesas/ravb_main.c              |   5 +++-
 drivers/net/ethernet/renesas/sh_eth.c                 |  55 ++++++++++=
++++++++++++++++++++-----------
 drivers/net/ethernet/renesas/sh_eth.h                 |  25 ----------=
---------
 drivers/net/ethernet/sfc/ef10.c                       |  24 +++++++++-=
--------
 drivers/net/ethernet/sfc/efx.h                        |   5 ++++
 drivers/net/ethernet/sfc/farch.c                      |   2 +-
 drivers/net/ethernet/sfc/txc43128_phy.c               |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c     |   6 ++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |   9 ++++---
 drivers/net/geneve.c                                  |   2 --
 drivers/net/phy/mdio-mux.c                            |   7 +++++-
 drivers/net/phy/micrel.c                              |  13 ++++++++--
 drivers/net/ppp/pppoe.c                               |  14 ++++++++--=
-
 drivers/net/ppp/pptp.c                                |   6 +++++
 drivers/net/usb/cdc_mbim.c                            |  26 ++++++++++=
+++++++++-
 drivers/net/usb/cdc_ncm.c                             |  10 +++++++-
 drivers/net/usb/r8152.c                               |  21 +++-------=
------
 drivers/net/vxlan.c                                   |  75 ++++++++++=
++++++++++++++++++++++++++++++++++------------
 include/linux/netdevice.h                             |   2 +-
 include/linux/netfilter/nfnetlink.h                   |   2 +-
 include/linux/qed/common_hsi.h                        |   2 ++
 include/linux/qed/qed_chain.h                         |   3 ++-
 include/linux/rhashtable.h                            |  18 ++++++++--=
----
 include/net/dst.h                                     |  33 ++++++++++=
+++++++++++++++
 include/net/inet_sock.h                               |  27 ++++++++++=
++++++++---
 include/net/inetpeer.h                                |   1 +
 include/net/sctp/structs.h                            |   3 ++-
 include/net/sock.h                                    |   7 ++++--
 include/net/vxlan.h                                   |   2 +-
 include/net/xfrm.h                                    |  25 ++++++++++=
++-------
 include/uapi/linux/Kbuild                             |   1 +
 include/uapi/linux/openvswitch.h                      |   2 +-
 lib/rhashtable.c                                      |  67 ++++++++++=
+++++++++++++++++++---------------------
 net/ax25/af_ax25.c                                    |   3 +++
 net/batman-adv/distributed-arp-table.c                |   5 +++-
 net/batman-adv/routing.c                              |  19 ++++++++++=
++---
 net/batman-adv/translation-table.c                    |  16 +++++++++-=
--
 net/bluetooth/sco.c                                   |   3 +++
 net/core/skbuff.c                                     |   5 ++--
 net/core/sock.c                                       |   7 +++---
 net/decnet/af_decnet.c                                |   3 +++
 net/ipv4/af_inet.c                                    |   3 +++
 net/ipv4/fib_frontend.c                               |   9 +++++++
 net/ipv4/fou.c                                        |   3 ++-
 net/ipv4/netfilter/Kconfig                            |   1 +
 net/ipv4/tcp_ipv4.c                                   |   5 ++--
 net/ipv4/tcp_output.c                                 |  23 +++++++++-=
--------
 net/ipv6/addrconf.c                                   |   8 +++++-
 net/ipv6/af_inet6.c                                   |   3 +++
 net/ipv6/ip6_gre.c                                    |   8 +++---
 net/ipv6/netfilter/Kconfig                            |   1 +
 net/ipv6/tcp_ipv6.c                                   |   3 +--
 net/irda/af_irda.c                                    |   3 +++
 net/mac80211/cfg.c                                    |   3 +--
 net/mac80211/ieee80211_i.h                            |   4 +--
 net/mac80211/mlme.c                                   |  17 ++++++++--=
---
 net/mac80211/rx.c                                     |   3 +--
 net/mac80211/util.c                                   | 113 ++++++++++=
+++++++++++++++++++++++++++++++++++++----------------------------------=
----
 net/mac80211/vht.c                                    |  10 +++-----
 net/mpls/af_mpls.c                                    |  43 ++++++++++=
+++++++++++++---------
 net/mpls/mpls_iptunnel.c                              |   4 +--
 net/netfilter/nf_tables_api.c                         |  99 ++++++++++=
+++++++++++++++++++++++++---------------------------------------
 net/netfilter/nfnetlink.c                             |   4 +--
 net/netfilter/nfnetlink_queue.c                       |   9 ++++---
 net/openvswitch/conntrack.c                           |  16 +++++++++-=
--
 net/rfkill/core.c                                     |   6 ++---
 net/sched/sch_api.c                                   |   2 +-
 net/sctp/ipv6.c                                       |  11 +++++++--
 net/sctp/outqueue.c                                   |   2 ++
 net/sctp/sm_make_chunk.c                              |   4 +--
 net/sctp/sm_statefuns.c                               |   3 ++-
 net/sctp/socket.c                                     |  12 ++++-----
 net/socket.c                                          |   1 +
 net/unix/af_unix.c                                    |  13 +++-------
 net/wireless/nl80211.c                                |   5 +++-
 net/wireless/reg.c                                    |   5 +++-
 net/xfrm/xfrm_policy.c                                |  50 ++++++++++=
+++++++++++++++++-----------
 115 files changed, 1045 insertions(+), 671 deletions(-)
