From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 31 Oct 2014 16:59:45 -0400 (EDT)
Message-ID: <20141031.165945.802957668535289170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A bit has accumulated, but it's been a week or so since my
last batch of post-merge-window fixes, so...

1) Missing module license in netfilter reject module, from Pablo.  Lots
   of people ran into this.

2) Off by one in mac80211 baserate calculation, from Karl Beldan.

3) Fix incorrect return value from ax88179_178a driver's set_mac_addr
   op, which broke use of it with bonding.  From Ian Morgan.

4) Checking of skb_gso_segment()'s return value was not all
   encompassing, it can return an SKB pointer, a pointer error, or
   NULL.  Fix from Florian Westphal.

   This is crummy, and longer term will be fixed to just return
   error pointers or a real SKB.

6) Encapsulation offloads not being handled by
   skb_gso_transport_seglen().  From Florian Westphal.

7) Fix deadlock in TIPC stack, from Ying Xue.

8) Fix performance regression from using rhashtable for netlink
   sockets.  The problem was the synchronize_net() invoked for
   every socket destroy.  From Thomas Graf.

9) Fix bug in eBPF verifier, and remove the strong dependency of
   BPF on NET.  From Alexei Starovoitov.

10) In qdisc_create(), use the correct interface to allocate
    ->cpu_bstats, otherwise the u64_stats_sync member isn't
    initialized properly.  From Sabrina Dubroca.

11) Off by one in ip_set_nfnl_get_byindex(), from Dan Carpenter.

12) nf_tables_newchain() was erroneously expecting error pointers
    from netdev_alloc_pcpu_stats().  It only returna a valid pointer
    or NULL.  From Sabrina Dubroca.

13) Fix use-after-free in _decode_session6(), from Li RongQing.

14) When we set the TX flow hash on a socket, we mistakenly do so
    before we've nailed down the final source port.  Move the setting
    deeper to fix this.  From Sathya Perla.

15) NAPI budget accounting in amd-xgbe driver was counting descriptors
    instead of full packets, fix from Thomas Lendacky.

16) Fix total_data_buflen calculation in hyperv driver, from Haiyang
    Zhang.

17) Fix bcma driver build with OF_ADDRESS disabled, from Hauke
    Mehrtens.

18) Fix mis-use of per-cpu memory in TCP md5 code.  The problem is that
    something that ends up being vmalloc memory can't be passed to
    the crypto hash routines via scatter-gather lists.  From Eric
    Dumazet.

19) Fix regression in promiscuous mode enabling in cdc-ether, from
    Olivier Blin.

20) Bucket eviction and frag entry killing can race with eachother,
    causing an unlink of the object from the wrong list.  Fix from
    Nikolay Aleksandrov.

21) Missing initialization of spinlock in cxgb4 driver, from Anish
    Bhatt.

22) Do not cache ipv4 routing failures, otherwise if the sysctl
    for forwarding is subsequently enabled this won't be seen.
    From Nicolas Cavallari.

Please pull, thanks a lot!

The following changes since commit 61ed53deb1c6a4386d8710dbbfcee8779c38=
1931:

  Merge tag 'ntb-3.18' of git://github.com/jonmason/ntb (2014-10-19 12:=
58:22 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 99a49ce613057f1934e1c378808374fd683b1541=
:

  Merge tag 'master-2014-10-30' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/linville/wireless (2014-10-31 16:18:35 -0400)

----------------------------------------------------------------

Alex Gartrell (1):
      ipvs: Avoid null-pointer deref in debug code

Alexei Starovoitov (2):
      bpf: fix bug in eBPF verifier
      bpf: split eBPF out of NET

Andrew Lunn (2):
      net: dsa: Error out on tagging protocol mismatches
      dsa: mv88e6171: Fix tagging protocol/Kconfig

Andy Shevchenko (1):
      stmmac: pci: set default of the filter bins

Anish Bhatt (3):
      cxgb4 : Improve handling of DCB negotiation or loss thereof
      cxgb4 : Handle dcb enable correctly
      cxgb4 : Fix missing initialization of win0_lock

Arturo Borrero (1):
      netfilter: nft_compat: fix wrong target lookup in nft_target_sele=
ct_ops()

Ben Hutchings (3):
      drivers/net: Disable UFO through virtio
      drivers/net, ipv6: Select IPv6 fragment idents for virtio UFO pac=
kets
      drivers/net: macvtap and tun depend on INET

Cyril Brulebois (1):
      wireless: rt2x00: add new rt2800usb device

Dan Carpenter (3):
      netfilter: ipset: off by one in ip_set_nfnl_get_byindex()
      i40e: _MASK vs _SHIFT typo in i40e_handle_mdd_event()
      ath9k: fix some debugfs output

David S. Miller (18):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'gso_encap_fixes'
      Merge branch 'enic'
      Merge branch 'amd-xgbe'
      Merge branch 'xen-netback'
      Merge branch 'mellanox'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'cxgb4-net'
      Merge branch 'dsa-net'
      Merge tag 'master-2014-10-27' of git://git.kernel.org/.../linvill=
e/wireless
      Merge branch 'systemport-net'
      Merge branch 'cdc-ether'
      Merge branch 'r8152-net'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'mellanox-net'
      Merge branch 'ufo-fix'
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'master-2014-10-30' of git://git.kernel.org/.../linvill=
e/wireless

David Vrabel (3):
      xen-netback: make feature-rx-notify mandatory
      xen-netback: fix unlimited guest Rx internal queue and carrier fl=
apping
      xen-netback: reintroduce guest Rx stall detection

Eli Cohen (2):
      net/mlx5_core: Call synchronize_irq() before freeing EQ buffer
      net/mlx4_core: Call synchronize_irq() before freeing EQ buffer

Emil Tantilov (1):
      ixgbe: fix race when setting advertised speed

Emmanuel Grumbach (6):
      iwlwifi: configure the LTR
      iwlwifi: mvm: BT Coex - update the MPLUT Boost register value
      iwlwifi: mvm: BT coex - fix BT prio for probe requests
      iwlwifi: dvm: drop non VO frames when flushing
      Revert "iwlwifi: mvm: treat EAPOLs like mgmt frames wrt rate"
      iwlwifi: pcie: fix polling in various places

Eric Dumazet (4):
      tcp: md5: do not use alloc_percpu()
      macvlan: fix a race on port dismantle and possible skb leaks
      net: napi_reuse_skb() should check pfmemalloc
      net: skb_fclone_busy() needs to detect orphaned skb

=46abian Frederick (1):
      net: rfkill: kernel-doc warning fixes

=46elix Fietkau (2):
      ath: use CTL region from cfg80211 if unset in EEPROM
      ath9k_common: always update value in ath9k_cmn_update_txpow

=46lorian Fainelli (2):
      net: systemport: enable RX interrupts after NAPI
      net: systemport: reset UniMAC coming out of a suspend cycle

=46lorian Westphal (5):
      net: gso: use feature flag argument in all protocol gso handlers
      net: make skb_gso_segment error handling more robust
      net: core: handle encapsulation offloads when computing segment l=
engths
      netfilter: nf_log: account for size of NLMSG_DONE attribute
      netfilter: nfnetlink_log: fix maximum packet length logged to use=
rspace

=46rancesco Ruggeri (1):
      e1000: unset IFF_UNICAST_FLT on WMware 82545EM

Geert Uytterhoeven (1):
      drivers: net: xgene: Rewrite buggy loop in xgene_enet_ecc_init()

Govindarajulu Varadarajan (2):
      enic: fix possible deadlock in enic_stop/ enic_rfs_flw_tbl_free
      enic: Do not call napi_disable when preemption is disabled.

Guenter Roeck (1):
      net: ethtool: Return -EOPNOTSUPP if user space tries to read EEPR=
OM with lengh 0

Haim Dreyfuss (1):
      iwlwifi: mvm: Add tx power condition to bss_info_changed_ap_ibss

Haiyang Zhang (1):
      hyperv: Fix the total_data_buflen in send path

Hariprasad Shenai (1):
      cxgb4vf: Replace repetitive pci device ID's with right ones

Hauke Mehrtens (1):
      bcma: fix build when CONFIG_OF_ADDRESS is not set

Herbert Xu (1):
      bridge: Do not compile options in br_parse_ip_options

Houcheng Lin (1):
      netfilter: nf_log: release skbuff on nlmsg put failure

Ian Morgan (1):
      ax88179_178a: fix bonding failure

John W. Linville (2):
      Merge tag 'iwlwifi-for-john-2014-10-23' of git://git.kernel.org/.=
=2E./iwlwifi/iwlwifi-fixes
      Merge tag 'mac80211-for-john-2014-10-23' of git://git.kernel.org/=
=2E../jberg/mac80211

Jon Cooper (1):
      sfc: remove incorrect EFX_BUG_ON_PARANOID check

Junwei Zhang (1):
      ixgbe: need not repeat init skb with NULL

Karl Beldan (3):
      mac80211: fix typo in starting baserate for rts_cts_rate_idx
      mac80211: minstrels: fix buffer overflow in HT debugfs rc_stats
      net: tso: fix unaligned access to crafted TCP header in helper AP=
I

Karsten Wiese (3):
      rtl8192cu: Fix for rtlwifi's bluetooth coexist functionality
      rtl8192cu: Call ieee80211_register_hw from rtl_usb_probe
      rtl8192cu: Prevent Ooops under rtl92c_set_fw_rsvdpagepkt

Kees Cook (1):
      rtlwifi: prevent format string usage from leaking

LEROY Christophe (1):
      net: fs_enet: set back promiscuity mode after restart

Larry Finger (8):
      rtlwifi: rtl8192ee: Prevent log spamming for switch statements
      rtlwifi: rtl8821ae: Fix possible array overrun
      rtlwifi: Add check for get_btc_status callback
      rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missin=
g get_btc_status
      rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw(=
)
      rtlwifi: rtl8192se: Add missing section to read descriptor settin=
g
      rtlwifi: rtl8192ce: Add missing section to read descriptor settin=
g
      rtlwifi: rtl8192se: Fix firmware loading

Lendacky, Thomas (2):
      amd-xgbe: Properly handle feature changes via ethtool
      amd-xgbe: Fix napi Rx budget accounting

Lennart Sorensen (2):
      drivers: net: cpsw: Fix broken loop condition in switch mode
      drivers: net: cpsw: Support ALLMULTI and fix IFF_PROMISC in switc=
h mode

Li RongQing (1):
      xfrm6: fix a potential use after free in xfrm6_policy.c

Liad Kaufman (2):
      mac80211: fix warning on htmldocs for last_tdls_pkt_time
      iwlwifi: 8000: fix string given to MODULE_FIRMWARE

Lubomir Rintel (1):
      ipv6: notify userspace when we added or changed an ipv6 token

Luciano Coelho (2):
      mac80211: return the vif's chandef in ieee80211_cfg_get_channel()
      nl80211: sanity check the channel switch counter value

Marc Yang (1):
      mwifiex: restart rxreorder timer correctly

Marcelo Leitner (1):
      netfilter: nf_conntrack: allow server to become a client in TW ha=
ndling

Matti Gottlieb (1):
      iwlwifi: mvm: ROC - bug fixes around time events and locking

Mugunthan V N (1):
      drivers: net:cpsw: fix probe_dt when only slave 1 is pinned out

Nicolas Cavallari (1):
      ipv4: Do not cache routing failures due to disabled forwarding.

Nikolay Aleksandrov (2):
      inet: frags: fix a race between inet_evict_bucket and inet_frag_k=
ill
      inet: frags: remove the WARN_ON from inet_evict_bucket

Olivier Blin (3):
      usbnet: add a callback for set_rx_mode
      cdc-ether: extract usbnet_cdc_update_filter function
      cdc-ether: handle promiscuous mode with a set_rx_mode callback

Or Gerlitz (2):
      net/mlx4_en: Don't attempt to TX offload the outer UDP checksum f=
or VXLAN
      mlx4: Avoid leaking steering rules on flow creation error flow

Pablo Neira Ayuso (12):
      netfilter: missing module license in the nf_reject_ipvX modules
      netfilter: nf_tables: restrict nat/masq expressions to nat chain =
type
      netfilter: nft_compat: fix hook validation for non-base chains
      netfilter: nft_compat: validate chain type in match/target
      netfilter: nft_nat: insufficient attribute validation
      netfilter: nft_nat: NFTA_NAT_REG_ADDR_MAX depends on NFTA_NAT_REG=
_ADDR_MIN
      netfilter: nft_nat: dump attributes if they are set
      netfilter: nf_tables_bridge: update hook_mask to allow {pre,post}=
routing
      netfilter: nf_reject_ipv4: split nf_send_reset() in smaller funct=
ions
      netfilter: nf_reject_ipv6: split nf_send_reset6() in smaller func=
tions
      netfilter: nft_reject_bridge: don't use IP stack to reject traffi=
c
      netfilter: nft_reject_bridge: restrict reject to prerouting and i=
nput

Philipp Zabel (1):
      net: fec: ptp: fix NULL pointer dereference if ptp_clock is not s=
et

Pravin B Shelar (2):
      mpls: Fix mpls_gso handler.
      mpls: Allow mpls_gso to be built as module

Rafa=A9=A9 Mi=A9=A9ecki (1):
      bcma: add another PCI ID of device with BCM43228

Randy Dunlap (1):
      skbuff.h: fix kernel-doc warning for headers_end

Richard Cochran (1):
      ptp: restore the makefile for building the test program.

Rickard Strandqvist (1):
      brcmfmac: dhd_sdio.c: Cleaning up missing null-terminate in conju=
nction with strncpy

Roman Gushchin (1):
      igb: don't reuse pages with pfmemalloc flag

Sabrina Dubroca (2):
      net: sched: initialize bstats syncp
      netfilter: nf_tables: check for NULL in nf_tables_newchain pcpu s=
tats allocation

Sathya Perla (1):
      net: fix saving TX flow hash in sock for outgoing connections

Sujith Manoharan (1):
      ath9k: Enable HW queue control only for MCC

Tej Parkash (1):
      cnic: Update the rcu_access_pointer() usages

Thomas Graf (1):
      netlink: Re-add locking to netlink_lookup() and seq walker

Tom Herbert (1):
      gre: Use inner mac length when computing tunnel length

Tony Lindgren (1):
      net: smc91x: Fix gpios for device tree based booting

Vince Bridgers (1):
      net: phy: Add SGMII Configuration for Marvell 88E1145 Initializat=
ion

WANG Cong (1):
      sch_pie: schedule the timer after all init succeed

Ying Xue (2):
      tipc: fix a potential deadlock
      tipc: fix lockdep warning when intra-node messages are delivered

hayeswang (4):
      r8152: clear SELECTIVE_SUSPEND when autoresuming
      r8152: reset tp->speed before autoresuming in open function
      r8152: check WORK_ENABLE in suspend function
      r8152: stop submitting intr for -EPROTO

 Documentation/devicetree/bindings/net/smsc-lan91c111.txt |   2 +
 Documentation/ptp/testptp.mk                             |  33 +++++
 arch/arm/boot/dts/omap3-n900.dts                         |   2 +
 arch/arm/mach-omap2/pdata-quirks.c                       |   3 -
 drivers/bcma/host_pci.c                                  |   5 +-
 drivers/bcma/main.c                                      |   2 +-
 drivers/infiniband/hw/mlx4/main.c                        |  10 +-
 drivers/net/Kconfig                                      |   2 +
 drivers/net/dsa/mv88e6171.c                              |   2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c                 |  22 +--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c        |  16 +--
 drivers/net/ethernet/broadcom/bcmsysport.c               |  11 +-
 drivers/net/ethernet/broadcom/cnic.c                     |   5 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c           |  55 +++++++=
-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          |   7 +-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c      |  16 +--
 drivers/net/ethernet/cisco/enic/enic_clsf.c              |  12 +-
 drivers/net/ethernet/cisco/enic/enic_main.c              |   4 +-
 drivers/net/ethernet/freescale/fec_main.c                |   3 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c         |   3 +
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c         |   3 +
 drivers/net/ethernet/intel/e1000/e1000_main.c            |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c              |   4 +-
 drivers/net/ethernet/intel/igb/igb_main.c                |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c         |   4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c            |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c               |   7 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c                  |   1 +
 drivers/net/ethernet/mellanox/mlx4/mcg.c                 |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c             |   1 +
 drivers/net/ethernet/sfc/tx.c                            |   4 -
 drivers/net/ethernet/smsc/smc91x.c                       |  58 +++++++=
+
 drivers/net/ethernet/smsc/smc91x.h                       |   3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c         |   7 +
 drivers/net/ethernet/ti/cpsw.c                           |  48 ++++---
 drivers/net/ethernet/ti/cpsw_ale.c                       |  29 ++++
 drivers/net/ethernet/ti/cpsw_ale.h                       |   2 +
 drivers/net/hyperv/netvsc_drv.c                          |   1 +
 drivers/net/macvlan.c                                    |  10 +-
 drivers/net/macvtap.c                                    |  16 +--
 drivers/net/phy/marvell.c                                |  19 +++
 drivers/net/tun.c                                        |  25 ++--
 drivers/net/usb/ax88179_178a.c                           |   7 +-
 drivers/net/usb/cdc_ether.c                              |  47 +++++--
 drivers/net/usb/r8152.c                                  |  17 ++-
 drivers/net/usb/usbnet.c                                 |  20 +++
 drivers/net/virtio_net.c                                 |  24 ++--
 drivers/net/wireless/ath/ath.h                           |   1 +
 drivers/net/wireless/ath/ath9k/common.c                  |   8 +-
 drivers/net/wireless/ath/ath9k/debug.c                   |   2 +-
 drivers/net/wireless/ath/ath9k/init.c                    |  55 ++++---=
-
 drivers/net/wireless/ath/ath9k/main.c                    |   3 +
 drivers/net/wireless/ath/ath9k/xmit.c                    |  10 +-
 drivers/net/wireless/ath/regd.c                          |  14 ++
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c       |  25 ++--
 drivers/net/wireless/iwlwifi/dvm/mac80211.c              |  24 ++--
 drivers/net/wireless/iwlwifi/iwl-8000.c                  |   3 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h                 |   2 +
 drivers/net/wireless/iwlwifi/mvm/coex.c                  |   4 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c           |   4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h          |  35 ++++-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h                |   1 +
 drivers/net/wireless/iwlwifi/mvm/fw.c                    |   9 ++
 drivers/net/wireless/iwlwifi/mvm/mac80211.c              |  32 +++--
 drivers/net/wireless/iwlwifi/mvm/ops.c                   |   1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c                  |   3 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c            |   2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c                    |   8 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c                |  22 +--
 drivers/net/wireless/mwifiex/11n_rxreorder.c             |  52 ++++++-=
-
 drivers/net/wireless/mwifiex/11n_rxreorder.h             |   2 +
 drivers/net/wireless/mwifiex/main.h                      |   1 +
 drivers/net/wireless/rt2x00/rt2800usb.c                  |   1 +
 drivers/net/wireless/rtlwifi/base.c                      |   2 +-
 drivers/net/wireless/rtlwifi/core.c                      |   6 +
 drivers/net/wireless/rtlwifi/core.h                      |   1 +
 drivers/net/wireless/rtlwifi/pci.c                       |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c        |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h             |   2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c              |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c              |   1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c             |   3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c              |  17 ++-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h              |   1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c              |   7 +
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c              |   1 +
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c              |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h             |   2 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c              |  22 +--
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c             |   3 +
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c             |  15 ++-
 drivers/net/wireless/rtlwifi/usb.c                       |  11 ++
 drivers/net/xen-netback/common.h                         |  39 +++---
 drivers/net/xen-netback/interface.c                      |  74 +++----=
---
 drivers/net/xen-netback/netback.c                        | 319 +++++++=
+++++++++++++++++++++----------------
 drivers/net/xen-netback/xenbus.c                         |  22 +--
 include/linux/skbuff.h                                   |  12 +-
 include/linux/usb/usbnet.h                               |   4 +
 include/net/ipv6.h                                       |   2 +
 include/net/netfilter/ipv4/nf_reject.h                   |  10 ++
 include/net/netfilter/ipv6/nf_reject.h                   |  10 ++
 include/net/netfilter/nf_tables.h                        |   3 +
 include/net/netfilter/nft_masq.h                         |   3 +
 init/Kconfig                                             |  14 ++
 kernel/Makefile                                          |   2 +-
 kernel/bpf/Makefile                                      |   6 +-
 kernel/bpf/core.c                                        |   9 ++
 kernel/bpf/verifier.c                                    |   3 +-
 net/Kconfig                                              |   2 +-
 net/bridge/br_forward.c                                  |   1 +
 net/bridge/br_netfilter.c                                |  24 +---
 net/bridge/netfilter/nf_tables_bridge.c                  |   6 +-
 net/bridge/netfilter/nft_reject_bridge.c                 | 296 +++++++=
+++++++++++++++++++++++++++++++--
 net/core/dev.c                                           |   4 +
 net/core/ethtool.c                                       |   6 +-
 net/core/skbuff.c                                        |  13 +-
 net/core/tso.c                                           |   3 +-
 net/dsa/dsa.c                                            |   5 +-
 net/ipv4/af_inet.c                                       |   2 +-
 net/ipv4/gre_offload.c                                   |   4 +-
 net/ipv4/inet_fragment.c                                 |   4 +-
 net/ipv4/ip_output.c                                     |   2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c                      |  91 +++++++=
++----
 net/ipv4/netfilter/nft_masq_ipv4.c                       |   1 +
 net/ipv4/route.c                                         |   1 +
 net/ipv4/tcp.c                                           |  59 +++----=
-
 net/ipv4/tcp_ipv4.c                                      |   4 +-
 net/ipv4/tcp_output.c                                    |   2 +-
 net/ipv4/udp_offload.c                                   |   2 +-
 net/ipv6/addrconf.c                                      |   1 +
 net/ipv6/ip6_offload.c                                   |   2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                      | 179 +++++++=
+++++++++---------
 net/ipv6/netfilter/nft_masq_ipv6.c                       |   1 +
 net/ipv6/output_core.c                                   |  34 +++++
 net/ipv6/tcp_ipv6.c                                      |   4 +-
 net/ipv6/xfrm6_policy.c                                  |  11 +-
 net/mac80211/cfg.c                                       |   2 +-
 net/mac80211/rate.c                                      |   2 +-
 net/mac80211/rc80211_minstrel_debugfs.c                  |  12 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c               |  13 +-
 net/mac80211/sta_info.h                                  |   1 +
 net/mpls/Makefile                                        |   2 +-
 net/mpls/mpls_gso.c                                      |   5 +-
 net/netfilter/ipset/ip_set_core.c                        |   2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                          |   4 +-
 net/netfilter/nf_conntrack_proto_tcp.c                   |   4 +-
 net/netfilter/nf_tables_api.c                            |  18 ++-
 net/netfilter/nfnetlink_log.c                            |  31 ++---
 net/netfilter/nfnetlink_queue_core.c                     |   2 +-
 net/netfilter/nft_compat.c                               |  81 +++++++=
++--
 net/netfilter/nft_masq.c                                 |  12 ++
 net/netfilter/nft_nat.c                                  |  86 +++++++=
-----
 net/netlink/af_netlink.c                                 |  37 +++--
 net/openvswitch/datapath.c                               |   2 +
 net/sched/sch_api.c                                      |   2 +-
 net/sched/sch_pie.c                                      |   2 +-
 net/tipc/node.c                                          |  46 ++++---
 net/tipc/node.h                                          |   7 +-
 net/tipc/socket.c                                        |   6 +-
 net/wireless/nl80211.c                                   |  10 +-
 net/xfrm/xfrm_output.c                                   |   2 +
 net/xfrm/xfrm_policy.c                                   |   2 +-
 samples/bpf/test_verifier.c                              |  11 ++
 164 files changed, 1943 insertions(+), 789 deletions(-)
 create mode 100644 Documentation/ptp/testptp.mk
