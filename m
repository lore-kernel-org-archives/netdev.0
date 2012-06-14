From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 13 Jun 2012 23:00:22 -0700 (PDT)
Message-ID: <20120613.230022.1655378156860678656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hey Linus, this has the fixes for the wireless issues you ran into the
other week as well as:

1) Fix CAN c_can driver transmit handling resulting in BUG check trigge=
rs,
   from AnilKumar Ch.

2) Fix packet drop monitor sleeping in atomic context, from Eric Dumaze=
t.

3) Fix mv643xx_eth driver build regression, from Andrew Lunn.

4) Inetpeer freeing needs an RCU grace period in order to avoid races
   during tree invalidation.  From Eric Dumazet.

5) Fix endianness bugs in xt_HMARK netfilter module, from Hans Schillst=
rom.

6) Add proper module refcounting to l2tp_eth to avoid crash on module
   unload, from Eric Dumazet.

7) Fix truncation of neighbour entry dumps due to logic errors in
   neigh_dump_info() and friends, from Eric Dumazet.

8) The conversion of fib6_age() to dst_neigh_lookup() accidently
   reversed the logic of a flags test, fix from Thomas Graf.

9) Fix checksum configuration in newer sky2 chips, from Stephen
   Hemminger.

10) Revert BQL support in NIU driver, doesn't work.

11) l2tp_ip_sendmsg() illegally uses a route without a proper reference=
=2E
    From Eric Dumazet.

12) be2net driver references an SKB after it's potentially been freed,
    also from Eric Dumazet.

13) Fix RCU stalls in dummy net driver init.  Also from Eric Dumazet.

14) lpc_eth has several bugs in it's transmit engine leading to packet
    leaks and improper queue wakes, from Eric Dumazet.

15) Apply short DMA workaround to more tg3 chips, from Matt Carlson.

16) Add tilegx network driver.

17) Bonding queue mapping for a packet can get corrupted, fix from
    Eric Dumazet.

18) Fix bug in netpoll_send_udp() SKB management that can leave garbage
    in the payload in certain situations.  From Eric Dumazet.

19) bnx2x driver interprets chip RX checksum offload incorrectly in
    encapsulation situations.  Fix from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit f8f5701bdaf9134b1f90e5044a82c66324d2=
073f:

  Linux 3.5-rc1 (2012-06-02 18:29:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to d6cb3e41386f20fb0777d0b59a2def82c65d37f7=
:

  bnx2x: fix checksum validation (2012-06-13 15:58:53 -0700)

----------------------------------------------------------------
Amitkumar Karwar (1):
      cfg80211: use sme_state in ibss start/join path

Andrew Lunn (1):
      mv643xx_eth: Fix compile error for architectures without clk.

AnilKumar Ch (3):
      can: c_can: fix "BUG! echo_skb is occupied!" during transmit
      can: c_can: fix an interrupt thrash issue with c_can driver
      can: c_can: fix race condition in c_can_open()

Arik Nemtsov (1):
      mac80211: fix non RCU-safe sta_list manipulation

Avinash Patil (2):
      mwifiex: invalidate bss config before setting channel for uAP
      mwifiex: support NL80211_HIDDEN_SSID_ZERO_LEN for uAP

Bj=F8rn Mork (1):
      net: sierra_net: device IDs for Aircard 320U++

Bruce Allan (1):
      e1000e: test for valid check_reset_block function pointer

Chris Metcalf (1):
      tilegx network driver: initial support

Chun-Yeow Yeoh (1):
      mac80211: Fix Unreachable Mesh Station Problem when joining to an=
other MBSS

Dave Jones (1):
      appletalk: Remove out of date message in printk

David S. Miller (4):
      Merge branch 'master' of git://gitorious.org/linux-can/linux-can
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Revert "niu: Add support for byte queue limits."
      Merge branch 'master' of git://1984.lsi.us.es/net

Emmanuel Grumbach (2):
      iwlwifi: don't mess up the SCD when removing a key
      iwlwifi: disable the buggy chain extension feature in HW

Eric Dumazet (13):
      drop_monitor: dont sleep in atomic context
      inetpeer: fix a race in inetpeer_gc_worker()
      net: l2tp_eth: fix kernel panic on rmmod l2tp_eth
      net: neighbour: fix neigh_dump_info()
      l2tp: fix a race in l2tp_ip_sendmsg()
      be2net: fix a race in be_xmit()
      virtio-net: fix a race on 32bit arches
      dummy: fix rcu_sched self-detected stalls
      lpc_eth: add missing ndo_change_mtu()
      lpc_eth: fix tx completion
      bonding: Fix corrupted queue_mapping
      netpoll: fix netpoll_send_udp() bugs
      bnx2x: fix checksum validation

=46elix Fietkau (1):
      mac80211: add missing rcu_read_lock/unlock in agg-rx session time=
r

Giuseppe CAVALLARO (5):
      net: icplus: fix interrupt mask
      stmmac: fix driver's doc when run kernel-doc script
      stmmac: update driver's doc
      stmmac: fix driver Kconfig when built as module
      stmmac: fix driver built w/ w/o both pci and platf modules

Haiyang Zhang (1):
      net/hyperv: Use wait_event on outstanding sends during device rem=
oval

Hans Schillstrom (1):
      netfilter: xt_HMARK: fix endianness and provide consistent hashin=
g

Hauke Mehrtens (1):
      bcma: fix null pointer in bcma_core_pci_irq_ctl

Joe Perches (3):
      can: cc770: Fix likely misuse of | for &
      mac80211: Fix likely misuse of | for &
      brcmfmac: Fix likely misuse of | for &

Johannes Berg (8):
      iwlwifi: fix TX power antenna access
      mac80211_hwsim: advertise interface combinations
      mac80211: clean up remain-on-channel on interface stop
      iwlwifi: disable WoWLAN if !CONFIG_PM_SLEEP
      iwlwifi: fix double free/complete in firmware loading
      iwlwifi: unregister LEDs if mac80211 registration fails
      cfg80211: fix interface combinations check
      wireless: add my new trees to MAINTAINERS

John Fastabend (2):
      ixgbe: fix_features rxvlan is independent of DCB and needs to be =
set
      ixgbe: IXGBE_RXD_STAT_VP set even with Rx stripping enabled

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Matt Carlson (1):
      tg3: Apply short DMA frag workaround to 5906

Meenakshi Venkataraman (2):
      mac80211: fix error in station state transitions during reconfig
      iwlwifi: use correct supported firmware for 6035 and 6000g2

Oleksij Rempel (1):
      b43: do not call ieee80211_unregister_hw if we are not registred

Pablo Neira Ayuso (1):
      netfilter: nf_ct_h323: fix bug in rtcp natting

Paul Pluzhnikov (1):
      net: Make linux/tcp.h C++ friendly (trivial)

Qasim Javed (1):
      mac80211_hwsim: Set IEEE80211_STAT_ACK flag when userspace indica=
tes that the frame has been acknowledged.

Randy Dunlap (2):
      net/core: fix kernel-doc warnings
      netdev: fix drivers/net/phy/ kernel-doc warnings

Roland Dreier (1):
      net: Reorder initialization in ip_route_output to fix gcc warning

Sasha Levin (1):
      NFC: Fix possible NULL ptr deref when getting the name of a socke=
t

Seth Forshee (1):
      bcma: add ext PA workaround for BCM4331 and BCM43431

Stanislav Yakovlev (1):
      net/wireless: ipw2100: Fix WARN_ON occurring in wiphy_register ca=
lled by ipw2100_pci_init_one

Stanislaw Gruszka (4):
      mac80211: run scan after finish connection monitoring
      rt2x00: use atomic variable for seqno
      rtl8187: ->brightness_set can not sleep
      mac80211: add back channel change flag

Stefan Roese (1):
      net: stmmac: Fix clock en-/disable calls

Thomas Graf (1):
      ipv6: fib: Restore NTF_ROUTER exception in fib6_age()

Vincent Bernat (1):
      snmp: fix OutOctets counter to include forwarded datagrams

Vinicius Costa Gomes (1):
      Bluetooth: Fix checking the wrong flag when accepting a socket

Weiping Pan (1):
      bonding:record primary when modify it via sysfs

fran=E7ois romieu (1):
      r8169: avoid NAPI scheduling delay.

stephen hemminger (1):
      sky2: fix checksum bit management on some chips

 Documentation/networking/stmmac.txt                   |   44 +-
 MAINTAINERS                                           |   12 +-
 drivers/bcma/driver_chipcommon_pmu.c                  |    4 +-
 drivers/bcma/driver_pci.c                             |    6 +-
 drivers/bcma/sprom.c                                  |    4 +-
 drivers/net/bonding/bond_main.c                       |    9 +-
 drivers/net/bonding/bond_sysfs.c                      |    8 +-
 drivers/net/can/c_can/c_can.c                         |   16 +-
 drivers/net/can/c_can/c_can.h                         |    1 +
 drivers/net/can/cc770/cc770_platform.c                |    2 +-
 drivers/net/dummy.c                                   |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h           |   15 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |   27 +-
 drivers/net/ethernet/broadcom/tg3.c                   |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |    5 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c           |    6 +-
 drivers/net/ethernet/intel/e1000e/mac.c               |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c            |    4 +-
 drivers/net/ethernet/intel/e1000e/phy.c               |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |   22 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c            |   15 +-
 drivers/net/ethernet/marvell/sky2.c                   |   10 +-
 drivers/net/ethernet/nxp/lpc_eth.c                    |   11 +-
 drivers/net/ethernet/realtek/r8169.c                  |    6 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig           |    4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |   63 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |   35 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      |   29 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    4 +-
 drivers/net/ethernet/sun/niu.c                        |   12 +-
 drivers/net/ethernet/tile/Kconfig                     |    2 +
 drivers/net/ethernet/tile/Makefile                    |    4 +-
 drivers/net/ethernet/tile/tilegx.c                    | 1898 +++++++++=
++++++++++++++++++++++++++++
 drivers/net/hyperv/hyperv_net.h                       |    1 +
 drivers/net/hyperv/netvsc.c                           |   12 +-
 drivers/net/phy/icplus.c                              |    7 +
 drivers/net/phy/mdio_bus.c                            |    2 +-
 drivers/net/usb/sierra_net.c                          |   14 +-
 drivers/net/virtio_net.c                              |   19 +-
 drivers/net/wireless/b43/b43.h                        |    4 +
 drivers/net/wireless/b43/main.c                       |   19 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c      |    4 +-
 drivers/net/wireless/ipw2x00/ipw2100.c                |   20 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c               |   23 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c                |    9 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c             |   18 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c           |    3 +
 drivers/net/wireless/iwlwifi/iwl-prph.h               |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c         |    5 +
 drivers/net/wireless/mac80211_hwsim.c                 |   22 +
 drivers/net/wireless/mwifiex/cfg80211.c               |   13 +
 drivers/net/wireless/mwifiex/fw.h                     |    6 +
 drivers/net/wireless/mwifiex/uap_cmd.c                |   10 +
 drivers/net/wireless/rt2x00/rt2x00.h                  |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c               |    1 -
 drivers/net/wireless/rt2x00/rt2x00queue.c             |   13 +-
 drivers/net/wireless/rtl818x/rtl8187/leds.c           |    2 +-
 include/linux/netfilter/xt_HMARK.h                    |    5 +
 include/linux/tcp.h                                   |   20 +-
 include/net/inetpeer.h                                |    5 +-
 include/net/route.h                                   |    2 +-
 include/net/sch_generic.h                             |    7 +-
 net/appletalk/ddp.c                                   |    4 +-
 net/bluetooth/af_bluetooth.c                          |    2 +-
 net/core/drop_monitor.c                               |  102 +-
 net/core/filter.c                                     |    4 +-
 net/core/neighbour.c                                  |   14 +-
 net/core/netpoll.c                                    |   11 +-
 net/core/skbuff.c                                     |    2 +-
 net/ipv4/inetpeer.c                                   |   16 +-
 net/ipv4/ip_forward.c                                 |    1 +
 net/ipv4/ipmr.c                                       |    1 +
 net/ipv6/ip6_fib.c                                    |    2 +-
 net/ipv6/ip6_output.c                                 |    1 +
 net/ipv6/ip6mr.c                                      |    2 +
 net/l2tp/l2tp_eth.c                                   |    2 +
 net/l2tp/l2tp_ip.c                                    |    9 +-
 net/mac80211/agg-rx.c                                 |    7 +-
 net/mac80211/cfg.c                                    |    6 +-
 net/mac80211/iface.c                                  |   12 +
 net/mac80211/mlme.c                                   |   38 +-
 net/mac80211/offchannel.c                             |   16 +
 net/mac80211/sta_info.c                               |    4 +-
 net/mac80211/tx.c                                     |    9 +-
 net/mac80211/util.c                                   |    2 +-
 net/netfilter/nf_conntrack_h323_main.c                |    5 +-
 net/netfilter/xt_HMARK.c                              |   72 +-
 net/nfc/llcp/sock.c                                   |    3 +
 net/wireless/ibss.c                                   |    6 +-
 net/wireless/util.c                                   |   19 +-
 91 files changed, 2550 insertions(+), 389 deletions(-)
 create mode 100644 drivers/net/ethernet/tile/tilegx.c
