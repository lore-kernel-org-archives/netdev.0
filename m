From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 27 Mar 2009 18:18:42 -0700 (PDT)
Message-ID: <20090327.181842.175175542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751737AbZC1BSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 21:18:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok these are the remaining bits for the networking merge window
submission.  There are some fixes for regressions from the pull from
two days ago as well.

1) Somehow Herbert's GRO fix slipped out of my tree the other
   day.  It's really here now, promise! :-)

2) smsc911x eeprom access fix from Steve Glendinning

3) ucc_geth PHY OOPS fixes from Anton Vorontsov

4) Rest of net_device_ops conversions that let x86 build with
   all drivers enabled and the netdev method compat code disabled.
   Nice work, Stephen Hemminger.

5) CXGB3 driver fixes from Divy Le Ray

6) OpenCores ethernet device driver from Thierry Reding.

7) Sync with the wireless folks, via John Linville.

8) Final netfilter updates from Patrick McHardy and crew.  Patrick
   is looking into a build failure reported by Randy Dunlap today
   so we'll have a fix for that soon.

9) Two small appletalk/af_rose/x25 cures from Alan Cox.  Someone is
   certainly barnstorming the kernel bugzilla lately :-)

10) Accidental double spinlock in xfrm-state handling, oops.  Fix from
    Chuck Ebbert and that is definitely on the way to -stable.

11) Fix MIPS build failure, linux/netdevice.h needs linux/mm.h to get
    page_address().  From Dmitri Vorobiev.

Please pull, thanks a lot!

The following changes since commit 0b4d569de222452bcb55a4a536ade6cf4d8d1e30:
  Linus Torvalds (1):
        i915: fix wrong 'size_t' format string

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (5):
      iwl3945: set TFD_QUEUE_MAX to correct value
      iwl3945: use iwl_cmd_queue_free
      iwl3945: fix checkpatch.pl errors
      iwl3945: control rate decrease
      iwl3945: replace stations with stations_39

Alan Cox (2):
      appletalk: this warning can go I think
      af_rose/x25: Sanity check the maximum user frame size

Alina Friedrichsen (1):
      mac80211: ieee80211_ibss_commit() cleanup

Anton Vorontsov (1):
      ucc_geth: Fix three oopses in PHY {de,}initialization code

Bob Copeland (4):
      ath5k: disable MIB interrupts
      ath5k: remove dummy PCI "retry timeout" fix
      ath5k: warn and correct rate for unknown hw rate indexes
      ath5k: properly drop packets from ops->tx

Christian Lamparter (9):
      p54: fix SoftLED compile dependencies
      ar9170: hardware and eeprom header files
      ar9170: ar9170: mac80211 interaction code
      ar9170: mac/bbp and phy code
      ar9170: ar9170: USB frontend driver
      ar9170: update Makefile, Kconfig and MAINTAINERS
      ar9170: simplify & deBUG tx_status queueing and reporting
      p54: Kconfig maintenance
      ar9170: single module build

Chuck Ebbert (1):
      xfrm: spin_lock() should be spin_unlock() in xfrm_state.c

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-next-2.6
      gianfar: Fix kfree(skb)
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Revert "netrom: zero length frame filtering in NetRom"
      Revert "ax25: zero length frame filtering in AX25"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Divy Le Ray (5):
      cxgb3: start qset timers when setup succeeded
      cxgb3: sge setup fixes
      cxgb3: use resource_size_t for mmio declarations
      cxgb3: differentiate portx and Tx channels
      cxgb3: map entire Rx page, feed map+offset to Rx ring.

Dmitri Vorobiev (1):
      net: Add missing include into include/linux/netdevice.h

Eric Dumazet (3):
      netfilter: nf_conntrack: use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
      netfilter: factorize ifname_compare()
      netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()

Geert Uytterhoeven (1):
      wireless/p54: P54_SPI should depend on GENERIC_HARDIRQS

Helmut Schaa (1):
      mac80211: start pending scan after probe/auth/assoc timed out

Herbert Xu (1):
      GRO: Disable GRO on legacy netif_rx path

Holger Eitzenberger (7):
      netfilter: ctnetlink: add callbacks to the per-proto nlattrs
      netlink: add nla_policy_len()
      netfilter: limit the length of the helper name
      netfilter: ctnetlink: allocate right-sized ctnetlink skb
      netfilter: nf_conntrack: add generic function to get len of generic policy
      netfilter: nf_conntrack: calculate per-protocol nlattr size
      ctnetlink: compute generic part of event more acurately

Ivo van Doorn (2):
      rt2x00: Update MAINTAINERS entry: new mailinglist
      rt2x00: New USB ID for rt73usb

Jesper Nilsson (1):
      ipv6: Plug sk_buff leak in ipv6_rcv (net/ipv6/ip6_input.c)

Johannes Berg (24):
      mac80211: remove ieee80211_num_regular_queues
      mac80211: reduce max number of queues
      mac80211: fix warnings in ieee80211_if_config
      mac80211: stop queues across suspend/resume
      wireless: radiotap updates
      nl80211: export supported commands
      mac80211: acquire sta_lock for station suspend/resume
      ieee80211: document DS bit usage
      nl80211: rework locking
      mac80211: kill IEEE80211_CONF_SHORT_SLOT_TIME
      mac80211: resume properly, add suspend/resume test
      cfg80211: accept no-op interface mode changes
      mac80211: remove mixed-cell and userspace MLME code
      mac80211: rate control status only for controlled packets
      mac80211: fix RX path
      cfg80211: fix locking in nl80211_set_wiphy
      mac80211: rewrite fragmentation
      mac80211: fix A-MPDU queue assignment
      mac80211: rework the pending packets code
      mac80211: clean up __ieee80211_tx args
      mac80211: unify and fix TX aggregation start
      mac80211: add skb length sanity checking
      mac80211: fix aggregation to not require queue stop
      mac80211/iwlwifi: move virtual A-MDPU queue bookkeeping to iwlwifi

Jouni Malinen (10):
      ath9k: Add support for multiple virtual AP interfaces
      mac80211: Fix a typo in assoc vs. reassoc check
      mac80211: Fix reassociation by not clearing previous BSSID
      nl80211: Event notifications for MLME events
      nl80211: Add MLME primitives to support external SME
      mac80211: Fix memleak in nl80211 authentication on deinit
      nl80211: Remove NL80211_CMD_SET_MGMT_EXTRA_IE
      nl80211: Add more through validation of MLME command parameters
      nl80211: Check that netif_runnin is true in cfg80211 code
      nl80211: Check iftype in cfg80211 code

Kalle Valo (6):
      mac80211: don't drop nullfunc frames during software scan
      mac80211: decrease execution of the associated timer
      mac80211: track beacons separately from the rx path activity
      mac80211: disable power save when scanning
      cfg80211: add feature to hold bss
      mac80211: add beacon filtering support

Li Yang (1):
      gianfar: only check headroom when FCB is needed

Lorenzo Nava (1):
      b43: fix b43_plcp_get_bitrate_idx_ofdm return type

Luis R. Rodriguez (8):
      ath9k: remove dummy PCI "retry timeout" fix
      mac80211_hwsim: let the reg workqueue breathe when regtest is set
      cfg80211: force last_request to be set for OLD_REG if regdom is EU
      cfg80211: fix incorrect assumption on last_request for 11d
      cfg80211: make regdom module parameter available oustide of OLD_REG
      cfg80211: remove code about country IE support with OLD_REG
      ath9k: fix dma mapping leak of rx buffer upon rmmod
      cfg80211: default CONFIG_WIRELESS_OLD_REGULATORY to n

Michael Buesch (3):
      b43: Mask PHY TX error interrupt, if not debugging
      ssb: remove EXPERIMENTAL dependencies.
      b43: Add BCM4307 PCI-ID

Mohamed Abbas (5):
      iwlagn: use changed in mac_config
      iwl3945: use changed in iwl3945_mac_config
      iwlagn: allow power level setting all the times
      iwlcore: dont commit power command if interface is not up
      iwlwifi: support 11h

Nick Kossifidis (3):
      ath5k: Choose the right initvals for RF2425
      ath5k: Convert chip specific calibration data to a generic format
      ath5k: Add tx power calibration support

Pat Erley (1):
      Add mesh point functionality to ath9k

Patrick McHardy (2):
      netfilter: fix xt_LED build failure
      netfilter: {ip,ip6,arp}_tables: fix incorrect loop detection

Reinette Chatre (1):
      cfg80211/nl80211: remove usage of CONFIG_NL80211

Stephen Hemminger (32):
      benet: use do_div() for 64 bit divide
      gianfar: fix headroom expansion code
      3c503, smc-ultra: netdev_ops bugs
      uml: convert network device to internal network device stats
      uml: convert network device to netdevice ops
      appletalk: convert cops to internal net_device_stats
      appltetalk: convert cops device to net_device ops
      appletalk: convert LTPC to use internal net_device_stats
      appletalk: convert LTPC to net_device_ops
      IRDA: convert donauboe to net_device_ops
      tokenring: convert drivers to net_device_ops
      tokenring: convert smctr to net_device_ops
      wan: convert sdla driver to net_device_ops
      wireless: convert arlan to net_device_ops
      wireless: convert wavelan to net_device_ops
      netdev: seeq8005 convert to net_device_ops
      netdev: smc9194 convert to net_device_ops
      netdev: smc-ultra32 convert to net_device_ops
      netdev: smc-ultra fix netpoll
      lance: convert to net_device_ops
      netdev: ibmlana convert to net_device_ops
      netdev: convert eexpress to net_device_ops
      netdev: convert eexpro to net_device_ops
      netdev: convert at1700 to net_device_ops
      netdev: convert depca to net_device_ops
      netdev: convert ewrk3 to net_device_ops
      netdev: convert ni52 to net_device_ops
      netdev: convert ni65 to net_device_ops
      netdev: convert ac3200 to net_device_ops
      netdev: convert lp486e to net_device_ops
      netdev: convert cs89x0 to net_device_ops
      netdev: convert eth16i to net_device_ops

Steve Glendinning (1):
      smsc911x: enforce read-after-write timing restriction on eeprom access

Sujith (9):
      ath9k: Miscellaneous EEPROM handling cleanup
      ath9k: Move AR5416_VER_MASK to a common location
      ath9k: Introduce a helper function for setting board gain values
      ath9k: Change return type for set_board_values()
      ath9k: Fix bug in 4K EEPROM size calculation
      ath9k: Fill in ack signal in TX status
      ath9k: Fix bug in handling single stream stations
      ath9k: Update copyright in all the files
      mac80211: Tear down aggregation sessions for suspend/resume

Thierry Reding (1):
      net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.

Tulio Magno Quites Machado Filho (1):
      ath5k: Support LED's on Acer Extensa 5620z

Vasanthakumar Thiagarajan (6):
      ath9k: Set IEEE80211_TX_CTL_RATE_CTRL_PROBE in rate control for probe rate
      mac80211: Populate HT limitation with TKIP/WEP to the handler for SIOCSIWENCODE too
      ath9k: Keep LED on in idle state after association
      ath9k: Fix rate control update for aggregated frames
      ath9k: Fix bug in reporting status of tx rate
      ath9k: Nuke struct ath_xmit_status

Wey-Yi Guy (3):
      iwlwifi: return 0 for AMPDU_TX/RX_STOP request if NIC is going down
      iwlwifi: report error when detect failure during stop agg queue
      iwlwifi: show current driver status in user readable format

 Documentation/DocBook/mac80211.tmpl                |    6 +
 Documentation/feature-removal-schedule.txt         |   37 +-
 MAINTAINERS                                        |   10 +-
 arch/um/drivers/net_kern.c                         |   39 +-
 arch/um/include/shared/net_kern.h                  |    2 +-
 drivers/net/3c503.c                                |    3 -
 drivers/net/Kconfig                                |    8 +
 drivers/net/Makefile                               |    1 +
 drivers/net/ac3200.c                               |   22 +-
 drivers/net/appletalk/cops.c                       |   45 +-
 drivers/net/appletalk/ltpc.c                       |   38 +-
 drivers/net/at1700.c                               |   19 +-
 drivers/net/benet/be_main.c                        |   28 +-
 drivers/net/cs89x0.c                               |   28 +-
 drivers/net/cxgb3/adapter.h                        |    4 +
 drivers/net/cxgb3/common.h                         |    4 +-
 drivers/net/cxgb3/cxgb3_main.c                     |   12 +-
 drivers/net/cxgb3/sge.c                            |  164 ++-
 drivers/net/cxgb3/t3_hw.c                          |   80 +-
 drivers/net/depca.c                                |   19 +-
 drivers/net/eepro.c                                |   17 +-
 drivers/net/eexpress.c                             |   17 +-
 drivers/net/eth16i.c                               |   18 +-
 drivers/net/ethoc.c                                | 1112 +++++++++++++
 drivers/net/ewrk3.c                                |   19 +-
 drivers/net/gianfar.c                              |   48 +-
 drivers/net/ibmlana.c                              |   17 +-
 drivers/net/irda/donauboe.c                        |   12 +-
 drivers/net/lance.c                                |   19 +-
 drivers/net/lp486e.c                               |   17 +-
 drivers/net/ni52.c                                 |   21 +-
 drivers/net/ni65.c                                 |   75 +-
 drivers/net/seeq8005.c                             |   17 +-
 drivers/net/smc-ultra.c                            |    5 +-
 drivers/net/smc-ultra32.c                          |   23 +-
 drivers/net/smc9194.c                              |   17 +-
 drivers/net/smsc911x.c                             |    5 +
 drivers/net/tokenring/madgemc.c                    |   11 +-
 drivers/net/tokenring/proteon.c                    |    9 +-
 drivers/net/tokenring/skisa.c                      |    9 +-
 drivers/net/tokenring/smctr.c                      |   16 +-
 drivers/net/ucc_geth.c                             |   21 +-
 drivers/net/wan/sdla.c                             |   36 +-
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    1 +
 drivers/net/wireless/ar9170/Kconfig                |   17 +
 drivers/net/wireless/ar9170/Makefile               |    3 +
 drivers/net/wireless/ar9170/ar9170.h               |  209 +++
 drivers/net/wireless/ar9170/cmd.c                  |  129 ++
 drivers/net/wireless/ar9170/cmd.h                  |   91 ++
 drivers/net/wireless/ar9170/eeprom.h               |  179 +++
 drivers/net/wireless/ar9170/hw.h                   |  417 +++++
 drivers/net/wireless/ar9170/led.c                  |  171 ++
 drivers/net/wireless/ar9170/mac.c                  |  452 ++++++
 drivers/net/wireless/ar9170/main.c                 | 1671 ++++++++++++++++++++
 drivers/net/wireless/ar9170/phy.c                  | 1240 +++++++++++++++
 drivers/net/wireless/ar9170/usb.c                  |  748 +++++++++
 drivers/net/wireless/ar9170/usb.h                  |   74 +
 drivers/net/wireless/arlan-main.c                  |   21 +-
 drivers/net/wireless/ath5k/ath5k.h                 |   35 +-
 drivers/net/wireless/ath5k/attach.c                |    2 +
 drivers/net/wireless/ath5k/base.c                  |   46 +-
 drivers/net/wireless/ath5k/base.h                  |    2 +-
 drivers/net/wireless/ath5k/desc.c                  |    4 +
 drivers/net/wireless/ath5k/eeprom.c                |  774 +++++++---
 drivers/net/wireless/ath5k/eeprom.h                |  128 +-
 drivers/net/wireless/ath5k/initvals.c              |    4 +-
 drivers/net/wireless/ath5k/led.c                   |    2 +
 drivers/net/wireless/ath5k/phy.c                   | 1170 +++++++++++++-
 drivers/net/wireless/ath5k/reg.h                   |   19 +
 drivers/net/wireless/ath5k/reset.c                 |   35 +-
 drivers/net/wireless/ath9k/ahb.c                   |    2 +-
 drivers/net/wireless/ath9k/ani.c                   |    2 +-
 drivers/net/wireless/ath9k/ani.h                   |    2 +-
 drivers/net/wireless/ath9k/ath9k.h                 |    9 +-
 drivers/net/wireless/ath9k/beacon.c                |   56 +-
 drivers/net/wireless/ath9k/calib.c                 |    2 +-
 drivers/net/wireless/ath9k/calib.h                 |    2 +-
 drivers/net/wireless/ath9k/debug.c                 |    2 +-
 drivers/net/wireless/ath9k/debug.h                 |    2 +-
 drivers/net/wireless/ath9k/eeprom.c                |  308 ++---
 drivers/net/wireless/ath9k/eeprom.h                |    5 +-
 drivers/net/wireless/ath9k/hw.c                    |   14 +-
 drivers/net/wireless/ath9k/hw.h                    |    2 +-
 drivers/net/wireless/ath9k/initvals.h              |    2 +-
 drivers/net/wireless/ath9k/mac.c                   |    2 +-
 drivers/net/wireless/ath9k/mac.h                   |    2 +-
 drivers/net/wireless/ath9k/main.c                  |   47 +-
 drivers/net/wireless/ath9k/pci.c                   |   20 +-
 drivers/net/wireless/ath9k/phy.c                   |    2 +-
 drivers/net/wireless/ath9k/phy.h                   |    2 +-
 drivers/net/wireless/ath9k/rc.c                    |   23 +-
 drivers/net/wireless/ath9k/rc.h                    |    2 +-
 drivers/net/wireless/ath9k/recv.c                  |    9 +-
 drivers/net/wireless/ath9k/reg.h                   |    2 +-
 drivers/net/wireless/ath9k/regd.c                  |    2 +-
 drivers/net/wireless/ath9k/regd.h                  |    2 +-
 drivers/net/wireless/ath9k/regd_common.h           |    2 +-
 drivers/net/wireless/ath9k/xmit.c                  |   78 +-
 drivers/net/wireless/b43/main.c                    |    2 +
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   24 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  179 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   54 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    6 +
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   52 +
 drivers/net/wireless/iwlwifi/iwl-power.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   18 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   38 +-
 drivers/net/wireless/libertas/radiotap.h           |   10 -
 drivers/net/wireless/libertas/rx.c                 |   12 +-
 drivers/net/wireless/mac80211_hwsim.c              |    4 +-
 drivers/net/wireless/p54/Kconfig                   |   39 +-
 drivers/net/wireless/p54/p54common.c               |   16 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    2 +
 drivers/net/wireless/wavelan.c                     |   79 +-
 drivers/net/wireless/wavelan.p.h                   |    9 +-
 drivers/ssb/Kconfig                                |   16 +-
 drivers/ssb/b43_pci_bridge.c                       |    1 +
 include/linux/ieee80211.h                          |   17 +
 include/linux/if_frad.h                            |    1 -
 include/linux/netdevice.h                          |    1 +
 include/linux/netfilter/x_tables.h                 |   23 +
 include/linux/nl80211.h                            |   88 +-
 include/linux/pci_ids.h                            |    2 +
 include/net/cfg80211.h                             |  203 +++-
 include/net/ethoc.h                                |   22 +
 include/net/ieee80211_radiotap.h                   |    4 +-
 include/net/mac80211.h                             |   84 +-
 include/net/netfilter/nf_conntrack.h               |   14 +-
 include/net/netfilter/nf_conntrack_helper.h        |    2 +
 include/net/netfilter/nf_conntrack_l3proto.h       |    7 +
 include/net/netfilter/nf_conntrack_l4proto.h       |    7 +
 include/net/netfilter/nf_conntrack_tuple.h         |    6 +-
 include/net/netlink.h                              |    1 +
 include/net/netns/conntrack.h                      |    5 +-
 lib/nlattr.c                                       |   27 +
 net/appletalk/ddp.c                                |    6 +-
 net/ax25/af_ax25.c                                 |   12 -
 net/core/dev.c                                     |    9 +-
 net/ipv4/netfilter/arp_tables.c                    |   18 +-
 net/ipv4/netfilter/ip_tables.c                     |   27 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    6 +
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   63 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |    6 +
 net/ipv4/netfilter/nf_nat_core.c                   |    2 +-
 net/ipv6/ip6_input.c                               |    4 +-
 net/ipv6/netfilter/ip6_tables.c                    |   27 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |    6 +
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |    6 +
 net/mac80211/agg-rx.c                              |    8 +
 net/mac80211/agg-tx.c                              |  232 ++--
 net/mac80211/cfg.c                                 |  245 ++--
 net/mac80211/debugfs.c                             |   24 +
 net/mac80211/ibss.c                                |    3 +-
 net/mac80211/ieee80211_i.h                         |   78 +-
 net/mac80211/iface.c                               |   14 +-
 net/mac80211/main.c                                |   25 +-
 net/mac80211/mlme.c                                |  259 +++-
 net/mac80211/pm.c                                  |   78 +-
 net/mac80211/rate.c                                |    6 +-
 net/mac80211/rate.h                                |    4 +-
 net/mac80211/rx.c                                  |   29 +-
 net/mac80211/scan.c                                |   77 +-
 net/mac80211/sta_info.c                            |   17 +-
 net/mac80211/sta_info.h                            |    7 +-
 net/mac80211/tx.c                                  |  579 ++++---
 net/mac80211/util.c                                |  126 +--
 net/mac80211/wep.c                                 |   21 +-
 net/mac80211/wext.c                                |   33 +-
 net/mac80211/wpa.c                                 |   28 +-
 net/netfilter/Kconfig                              |    2 +-
 net/netfilter/nf_conntrack_core.c                  |  129 +-
 net/netfilter/nf_conntrack_expect.c                |    2 +-
 net/netfilter/nf_conntrack_helper.c                |    8 +-
 net/netfilter/nf_conntrack_netlink.c               |   94 +-
 net/netfilter/nf_conntrack_proto.c                 |   16 +
 net/netfilter/nf_conntrack_proto_dccp.c            |    9 +
 net/netfilter/nf_conntrack_proto_gre.c             |    1 +
 net/netfilter/nf_conntrack_proto_sctp.c            |   10 +
 net/netfilter/nf_conntrack_proto_tcp.c             |   15 +
 net/netfilter/nf_conntrack_proto_udp.c             |    2 +
 net/netfilter/nf_conntrack_proto_udplite.c         |    1 +
 net/netfilter/nf_conntrack_standalone.c            |   57 +-
 net/netfilter/xt_connlimit.c                       |    6 +-
 net/netfilter/xt_physdev.c                         |   21 +-
 net/netrom/af_netrom.c                             |   17 +-
 net/rose/af_rose.c                                 |    4 +
 net/wireless/Kconfig                               |   44 +-
 net/wireless/Makefile                              |    3 +-
 net/wireless/core.c                                |   30 +-
 net/wireless/core.h                                |    5 +
 net/wireless/mlme.c                                |   46 +
 net/wireless/nl80211.c                             |  824 ++++++++--
 net/wireless/nl80211.h                             |   38 +-
 net/wireless/reg.c                                 |   65 +-
 net/wireless/scan.c                                |   27 +-
 net/wireless/wext-compat.c                         |   11 +-
 net/x25/af_x25.c                                   |    6 +
 net/xfrm/xfrm_state.c                              |    2 +-
 207 files changed, 12318 insertions(+), 2765 deletions(-)
 create mode 100644 drivers/net/ethoc.c
 create mode 100644 drivers/net/wireless/ar9170/Kconfig
 create mode 100644 drivers/net/wireless/ar9170/Makefile
 create mode 100644 drivers/net/wireless/ar9170/ar9170.h
 create mode 100644 drivers/net/wireless/ar9170/cmd.c
 create mode 100644 drivers/net/wireless/ar9170/cmd.h
 create mode 100644 drivers/net/wireless/ar9170/eeprom.h
 create mode 100644 drivers/net/wireless/ar9170/hw.h
 create mode 100644 drivers/net/wireless/ar9170/led.c
 create mode 100644 drivers/net/wireless/ar9170/mac.c
 create mode 100644 drivers/net/wireless/ar9170/main.c
 create mode 100644 drivers/net/wireless/ar9170/phy.c
 create mode 100644 drivers/net/wireless/ar9170/usb.c
 create mode 100644 drivers/net/wireless/ar9170/usb.h
 create mode 100644 include/net/ethoc.h
 create mode 100644 net/wireless/mlme.c
