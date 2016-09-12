From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 11 Sep 2016 20:08:25 -0700 (PDT)
Message-ID: <20160911.200825.1735122029283603358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756235AbcILDI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 23:08:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mostly small sets of driver fixes scattered all over the place.

1) Mediatek driver fixes from Sean Wang.  Forward port not written
   correctly during TX map, missed handling of EPROBE_DEFER, and
   mistaken use of put_page() instead of skb_free_frag().

2) Fix socket double-free in KCM code, from WANG Cong.

3) QED driver fixes from Sudarsana Reddy Kalluru, including a fix
   for using the dcbx buffers before initializing them.

4) Mellanox Switch driver fixes from Jiri Pirko, including a fix for
   double fib removals and an error handling fix in
   mlxsw_sp_module_init().

5) Fix kernel panic when enabling LLDP in i40e driver, from Dave
   Ertman.

6) Fix padding of TSO packets in thunderx driver, from Sunil Goutham.

7) TCP's rcv_wup not initialized properly when using fastopen, from
   Neal Cardwell.

8) Don't use uninitialized flow keys in flow dissector, from Gao
   Feng.

9) Use after free in l2tp module unload, from Sabrina Dubroca.

10) Fix interrupt registry ordering issues in smsc911x driver, from
    Jeremy Linton.

11) Fix crashes in bonding having to do with enslaving and rx_handler,
    from Mahesh Bandewar.

12) AF_UNIX deadlock fixes from Linus.

13) In mlx5 driver, don't read skb->xmit_mode after it might have been
    freed from the TX reclaim path.  From Tariq Toukan.

14) Fix a bug from 2015 in TCP Yeah where the congestion window does
    not increase, from Artem Germanov.

15) Don't pad frames on receive in NFP driver, from Jakub Kicinski.

16) Fix chunk fragmenting in SCTP wrt. GSO, from Marcelo Ricardo
    Leitner.

17) Fix deletion of VRF routes, from Mark Tomlinson.

18) Fix device refcount leak when DAD fails in ipv6, from Wei Yongjun.

Please pull, thanks a lot!

The following changes since commit e4e98c460ad38c78498622a164fd5ef09a2dc9cb:

  Merge tag 'hwmon-for-linus-v4.8-rc5' of git://git.kernel.org/pub/scm/linux/kernel/git/groeck/linux-staging (2016-08-29 19:12:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 373df3131aa83bd3e0ea7cd15be92d942d75fc72:

  Merge branch 'mlx4-fixes' (2016-09-11 19:40:26 -0700)

----------------------------------------------------------------
Alexey Kodanev (1):
      net/xfrm_input: fix possible NULL deref of tunnel.ip6->parms.i_key

Andy Gospodarek (1):
      MAINTAINERS: update to working email address

Arend Van Spriel (1):
      brcmfmac: avoid potential stack overflow in brcmf_cfg80211_start_ap()

Arik Nemtsov (1):
      mac80211: TDLS: don't require beaconing for AP BW

Artem Germanov (1):
      tcp: cwnd does not increase in TCP YeAH

Ashok Raj Nagarajan (1):
      ath10k: fix get rx_status from htt context

Bodong Wang (1):
      net/mlx5e: Move an_disable_cap bit to a new position

Cathy Luo (1):
      mwifiex: fix large amsdu packets causing firmware hang

Chris Brandt (1):
      net: ethernet: renesas: sh_eth: add POST registers for rz

Dave Ertman (1):
      i40e: Fix kernel panic on enable/disable LLDP

Dave Jones (1):
      ipv6: release dst in ping_v6_sendmsg

David Ahern (1):
      xfrm: Only add l3mdev oif to dst lookups

David S. Miller (15):
      Merge tag 'mac80211-for-davem-2016-08-30' of git://git.kernel.org/.../jberg/mac80211
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mediatek-fixes'
      Merge branch 'qed-fixes'
      Merge branch 'mlxsw-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-08-29' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'thunderx-fixes'
      Merge branch 'smsc911x-fixes'
      Merge branch 'vxlan-fixes'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'mlx5-fixes'
      Merge branch 'nfp-fixes'
      Merge branch 'mlxsw-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-09-08' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'mlx4-fixes'

Davide Caratti (1):
      bridge: re-introduce 'fix parsing of MLDv2 reports'

Eli Cooper (1):
      ipv6: Don't unset flowi6_proto in ipxip6_tnl_xmit()

Emmanuel Grumbach (2):
      iwlwifi: mvm: consider P2p device type for firmware dump triggers
      iwlwifi: mvm: don't use ret when not initialised

Eric Dumazet (1):
      tcp: fastopen: avoid negative sk_forward_alloc

Felix Fietkau (2):
      ath9k: fix client mode beacon configuration
      ath9k: fix using sta->drv_priv before initializing it

Florian Fainelli (1):
      MAINTAINERS: Update CPMAC email address

Gal Pressman (3):
      net/mlx5e: Prevent casting overflow
      net/mlx5e: Fix global PFC counters replication
      net/mlx5e: Fix parsing of vlan packets when updating lro header

Gao Feng (1):
      rps: flow_dissector: Fix uninitialized flow_keys used in __skb_get_hash possibly

Giedrius Statkevièius (1):
      ath9k: bring back direction setting in ath9k_{start_stop}

Guilherme G. Piccoli (1):
      bnx2x: don't reset chip on cleanup if PCI function is offline

Helmut Buchsbaum (1):
      net: macb: initialize checksum when using checksum offloading

Ido Schimmel (3):
      mlxsw: spectrum: Don't take multiple references on a FID
      mlxsw: spectrum: Use existing flood setup when adding VLANs
      mlxsw: spectrum: Set port type before setting its address

Ivan Vecera (1):
      tg3: Fix for disallow tx coalescing time to be 0

Jakub Kicinski (3):
      nfp: remove linux/version.h includes
      nfp: drop support for old firmware ABIs
      nfp: don't pad frames on receive

Jean Delvare (1):
      drivers: net: phy: mdio-xgene: Add hardware dependency

Jeremy Linton (4):
      net: smsc911x: Remove multiple exit points from smsc911x_open
      net: smsc911x: Fix register_netdev, phy startup, driver unload ordering
      net: smsc911x: Move interrupt handler before open
      net: smsc911x: Move interrupt allocation to open/stop

Jiri Benc (2):
      vxlan: reject multicast destination without an interface
      vxlan: fix duplicated and wrong error messages

Jiri Pirko (5):
      mlxsw: spectrum_router: Fix failure caused by double fib removal from HW
      mlxsw: spectrum_router: Fix fib entry update path
      mlxsw: spectrum: Fix error path in mlxsw_sp_module_init
      mlxsw: spectrum_router: Fix netevent notifier registration
      mlxsw: spectrum_router: Fix error path in mlxsw_sp_router_init

Johannes Berg (1):
      Revert "wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel"

Kalle Valo (3):
      Merge ath-current from ath.git
      Merge tag 'iwlwifi-for-kalle-2016-08-29' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Kamal Heib (2):
      net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_all()
      net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_state()

Lars Persson (1):
      dwc_eth_qos: do not register semi-initialized device

Linus Lüssing (1):
      cfg80211: Add stub for cfg80211_get_station()

Linus Torvalds (2):
      Revert "af_unix: Fix splice-bind deadlock"
      af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'

Liping Zhang (6):
      netfilter: nft_reject: restrict to INPUT/FORWARD/OUTPUT
      netfilter: nfnetlink: use list_for_each_entry_safe to delete all objects
      netfilter: cttimeout: put back l4proto when replacing timeout policy
      netfilter: cttimeout: unlink timeout objs in the unconfirmed ct lists
      netfilter: nft_meta: improve the validity check of pkttype set expr
      netfilter: nf_tables_netdev: remove redundant ip_hdr assignment

Mahesh Bandewar (1):
      bonding: Fix bonding crash

Marcelo Ricardo Leitner (1):
      sctp: identify chunks that need to be fragmented at IP level

Mark Tomlinson (1):
      net: Don't delete routes in different VRFs

Miaoqing Pan (1):
      ath9k: fix AR5416 access GPIO warning

Michael Chan (1):
      bnxt_en: Fix TX push operation on ARM64.

Mohammed Shafi Shajakhan (1):
      ath10k: Remove driver log suggesting QCA9887 support is experimental

Moshe Shemesh (1):
      net/mlx4_en: Fix panic on xmit while port is down

Neal Cardwell (1):
      tcp: fastopen: fix rcv_wup initialization for TFO server on SYN/data

Nicolas Dichtel (2):
      ipv6: add missing netconf notif when 'all' is updated
      netconf: add a notif when settings are created

Nikolay Aleksandrov (1):
      net: bridge: don't increment tx_dropped in br_do_proxy_arp

Parthasarathy Bhuvaragan (1):
      tipc: fix random link resets while adding a second bearer

Peer, Ilan (1):
      iwlwifi: mvm: Advertise support for AP channel width change

Sabrina Dubroca (2):
      netfilter: ebtables: put module reference when an incorrect extension is found
      l2tp: fix use-after-free during module unload

Sean Wang (9):
      net: ethernet: mediatek: fix fails from TX housekeeping due to incorrect port setup
      net: ethernet: mediatek: fix incorrect return value of devm_clk_get with EPROBE_DEFER
      net: ethernet: mediatek: fix API usage with skb_free_frag
      net: ethernet: mediatek: remove redundant free_irq for devm_request_irq allocated irq
      net: ethernet: mediatek: fix logic unbalance between probe and remove
      net: ethernet: mediatek: fix issue of driver removal with interface is up
      net: ethernet: mediatek: fix the missing of_node_put() after node is used done inside mtk_mdio_init
      net: ethernet: mediatek: use devm_mdiobus_alloc instead of mdiobus_alloc inside mtk_mdio_init
      net: ethernet: mediatek: fix error handling inside mtk_mdio_init

Sharon Dvir (1):
      iwlwifi: mvm: check if vif is NULL before using it

Sudarsana Reddy Kalluru (3):
      qed*: Disallow dcbx configuration for VF interfaces.
      qed: Set selection-field while configuring the app entry in ieee mode.
      qed: Clear dcbx memory buffers before the usage.

Sudip Mukherjee (1):
      net: smsc: remove build warning of duplicate definition

Sunil Goutham (2):
      net: thunderx: Fix for HW issue while padding TSO packet
      net: thunderx: Fix for issues with multiple CQEs posted for a TSO packet

Tariq Toukan (2):
      net/mlx5e: Fix xmit_more counter race issue
      net/mlx4_en: Fixes for DCBX

Tobias Brunner (1):
      xfrm: Ignore socket policies when rebuilding hash tables

Vegard Nossum (3):
      xfrm: fix crash in XFRM_MSG_GETSA netlink handler
      xfrm: get rid of incorrect WARN
      xfrm: get rid of another incorrect WARN

WANG Cong (1):
      kcm: fix a socket double free

Wei Yongjun (1):
      ipv6: addrconf: fix dev refcont leak when DAD failed

Wu Fengguang (1):
      qed: fix kzalloc-simple.cocci warnings

mhiramat@kernel.org (2):
      brcmfmac: Check rtnl_lock is locked when removing interface
      brcmfmac: Change vif_event_lock to spinlock

 MAINTAINERS                                                 |   4 +-
 drivers/net/bonding/bond_main.c                             |   7 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c            |  19 ++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                   |   4 +-
 drivers/net/ethernet/broadcom/tg3.c                         |  11 +---
 drivers/net/ethernet/cadence/macb.c                         |  23 ++++++++
 drivers/net/ethernet/cavium/thunder/nic.h                   |   1 +
 drivers/net/ethernet/cavium/thunder/nic_main.c              |  11 +++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c            |  20 +++++--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c          |  64 +++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c                 |  15 +++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.c                 |  82 +++++++++++++-------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h                 |  22 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c              |  57 +++++++++---------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c              |  21 +++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c                  |  12 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h                |  15 +----
 drivers/net/ethernet/mellanox/mlx4/port.c                   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c        |   8 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c             |  22 ++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c             |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c              |  28 ++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h              |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c       | 160 +++++++++++++++++++++++++++++++------------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c    |  28 ++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c         |   5 --
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c        |   1 -
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c         |   7 +--
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c                  |  20 ++++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c                |   3 +-
 drivers/net/ethernet/renesas/sh_eth.c                       |   7 +++
 drivers/net/ethernet/smsc/smc91x.h                          |   2 +
 drivers/net/ethernet/smsc/smsc911x.c                        | 213 ++++++++++++++++++++++++++++++++----------------------------------
 drivers/net/ethernet/synopsys/dwc_eth_qos.c                 |  38 ++++++------
 drivers/net/phy/Kconfig                                     |   1 +
 drivers/net/vxlan.c                                         |  38 ++++--------
 drivers/net/wireless/ath/ath10k/htt_rx.c                    |  10 ++--
 drivers/net/wireless/ath/ath10k/pci.c                       |   1 -
 drivers/net/wireless/ath/ath9k/hw.c                         |   4 +-
 drivers/net/wireless/ath/ath9k/main.c                       |  18 ++++--
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c |  28 ++++-----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c     |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c      |   8 ++-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.h      |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c             |   3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.h             |   3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c           |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h                |   2 +
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c             |   3 +-
 include/linux/mlx5/mlx5_ifc.h                               |   5 +-
 include/linux/netdevice.h                                   |   1 +
 include/net/af_unix.h                                       |   2 +-
 include/net/cfg80211.h                                      |   9 +++
 include/net/ip_fib.h                                        |   3 +-
 include/net/netfilter/nft_meta.h                            |   4 ++
 include/net/netfilter/nft_reject.h                          |   4 ++
 net/bridge/br_input.c                                       |   7 +--
 net/bridge/br_multicast.c                                   |   2 +-
 net/bridge/netfilter/ebtables.c                             |   2 +
 net/bridge/netfilter/nft_meta_bridge.c                      |   1 +
 net/core/dev.c                                              |  16 +++++
 net/core/flow_dissector.c                                   |   6 +-
 net/ipv4/devinet.c                                          |  11 ++--
 net/ipv4/fib_frontend.c                                     |   3 +-
 net/ipv4/fib_semantics.c                                    |   8 ++-
 net/ipv4/netfilter/nft_reject_ipv4.c                        |   1 +
 net/ipv4/tcp_fastopen.c                                     |   2 +
 net/ipv4/tcp_yeah.c                                         |   2 +-
 net/ipv4/xfrm4_policy.c                                     |   2 +-
 net/ipv6/addrconf.c                                         |  18 +++++-
 net/ipv6/ip6_tunnel.c                                       |   2 +
 net/ipv6/netfilter/nft_reject_ipv6.c                        |   1 +
 net/ipv6/ping.c                                             |   9 ++-
 net/ipv6/xfrm6_input.c                                      |   1 +
 net/ipv6/xfrm6_policy.c                                     |   2 +-
 net/kcm/kcmsock.c                                           |   3 +-
 net/l2tp/l2tp_core.c                                        |   3 +
 net/mac80211/tdls.c                                         |   7 ++-
 net/netfilter/nf_tables_netdev.c                            |   1 -
 net/netfilter/nfnetlink_acct.c                              |   6 +-
 net/netfilter/nfnetlink_cttimeout.c                         |  49 ++++++++-------
 net/netfilter/nft_meta.c                                    |  17 ++++--
 net/netfilter/nft_reject.c                                  |  16 +++++
 net/netfilter/nft_reject_inet.c                             |   7 ++-
 net/sctp/output.c                                           |  13 +++-
 net/tipc/name_distr.c                                       |   8 ++-
 net/unix/af_unix.c                                          | 111 +++++++++++++++-------------------
 net/wireless/wext-core.c                                    |  25 +-------
 net/xfrm/xfrm_input.c                                       |  14 ++---
 net/xfrm/xfrm_policy.c                                      |   4 ++
 net/xfrm/xfrm_user.c                                        |  13 ++--
 92 files changed, 875 insertions(+), 610 deletions(-)
