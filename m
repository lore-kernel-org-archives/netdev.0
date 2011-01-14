From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 14 Jan 2011 13:03:23 -0800 (PST)
Message-ID: <20110114.130323.201674039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) NAPI and SMP locking bug fixes in GRETH from Daniel Hellstrom.

2) Fix Cassini driver build on x86.

3) Fix unhandled IRQs in e1000, from Jesse Brandeburg.

4) SFC accidently stopped adhering to rss_cpus module parm, from
   Ben Hutchings.

5) IPV6 forwarding path must check skb->packet_type for PACKET_HOST,
   otherwise we get packet storms, fix from Alexey Kuznetsov.

6) rndis driver can deadlock in stats handling, part of the problem is
   the use of dev_txq_stats_fold() which makes this situation too easy
   to get into.  Kill the interface and convert the small number of
   existing users, thus fixing the rndis deadlocks.  From Eric Dumazet.

7) tproxy w/o conntrack build fix in netfilter, from KOVACS Krisztian.

8) ath9k wireless fixes from Sujith Manoharan.

9) Fix ctnetlink error signalling such that we don't loop forever
   in some situations, from Pablo Neira Ayuso.

10) Kernel doc fixups from Randy Dunlap.

11) Wireless stack kernel doc and other comment fixes from Johannes Ber=
g.

Please pull, thanks a lot!

The following changes since commit 4162cf64973df51fc885825bc9ca4d055891=
c49f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6 (20=
11-01-11 16:32:41 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Kuznetsov (1):
      inet6: prevent network storms caused by linux IPv6 routers

Ben Hutchings (4):
      sfc: Make efx_get_tx_queue() an inline function
      sfc: Restore the effect of the rss_cpus module parameter
      ks8695net: Disable non-working ethtool operations
      ks8695net: Use default implementation of ethtool_ops::get_link

Bruce Allan (2):
      e1000e: update Copyright for 2011
      e1000e: consistent use of Rx/Tx vs. RX/TX/rx/tx in comments/logs

Christian Lamparter (1):
      p54: fix sequence no. accounting off-by-one error

Daniel Hellstrom (7):
      GRETH: added raw AMBA vendor/device number to match against.
      GRETH: fix opening/closing
      GRETH: GBit transmit descriptor handling optimization
      GRETH: fixed skb buffer memory leak on frame errors
      GRETH: avoid writing bad speed/duplex when setting transfer mode
      GRETH: handle frame error interrupts
      GRETH: resolve SMP issues and other problems

David S. Miller (7):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://1984.lsi.us.es/net-2.6
      Merge branch 'master' of git://1984.lsi.us.es/net-2.6
      cassini: Fix build bustage on x86.
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost
      Merge branch 'master' of git://git.kernel.org/.../bwh/sfc-2.6
      Merge branch 'master' of master.kernel.org:/.../jkirsher/net-2.6

Eric Dumazet (1):
      net: remove dev_txq_stats_fold()

Indan Zupancic (1):
      ipw2200: Check for -1 INTA in tasklet too.

Jesper Juhl (2):
      vxge: Remember to release firmware after upgrading firmware
      USB CDC NCM: Don't deref NULL in cdc_ncm_rx_fixup() and don't use=
 uninitialized variable.

Jesse Brandeburg (1):
      e1000: Avoid unhandled IRQ

Joe Perches (2):
      bna: Remove unnecessary memset(,0,)
      netdev: bfin_mac: Remove is_multicast_ether_addr use in netdev_fo=
r_each_mc_addr

Johannes Berg (5):
      mac80211: add remain-on-channel docs
      mac80211: add missing docs for off-chan TX flag
      cfg80211: add mesh join/leave callback docs
      nl80211: add/fix mesh docs
      mac80211: add doc short section on LED triggers

KOVACS Krisztian (1):
      netfilter: fix compilation when conntrack is disabled but tproxy =
is enabled

Kees Cook (1):
      net: ax25: fix information leak to userland harder

Michael Buesch (1):
      ssb: Ignore dangling ethernet cores on wireless devices

Michael S. Tsirkin (1):
      vhost: fix signed/unsigned comparison

Nicolas Dichtel (1):
      ipsec: update MAX_AH_AUTH_LEN to support sha512

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix loop in ctnetlink_get_conntrack()

Randy Dunlap (1):
      eth: fix new kernel-doc warning

Stanislaw Gruszka (1):
      hostap_cs: fix sleeping function called from invalid context

Sujith Manoharan (5):
      ath9k_hw: Fix chip test
      ath9k_hw: Fix calibration for AR9287 devices
      ath9k_hw: Fix thermal issue with UB94
      ath9k_hw: Fix RX handling for USB devices
      ath9k_htc: Really fix packet injection

Tobias Klauser (4):
      netdev: ucc_geth: Use is_multicast_ether_addr helper
      netdev: bfin_mac: Use is_multicast_ether_addr helper
      etherdevice.h: Add is_unicast_ether_addr function
      netdev: tilepro: Use is_unicast_ether_addr helper

fran=E7ois romieu (1):
      r8169: keep firmware in memory.

stephen hemminger (1):
      sched: remove unused backlog in RED stats

 Documentation/DocBook/80211.tmpl               |   21 ++-
 drivers/net/arm/ks8695net.c                    |  288 ++++++++--------=
--------
 drivers/net/bfin_mac.c                         |    9 +-
 drivers/net/bna/bnad_ethtool.c                 |    1 -
 drivers/net/cassini.c                          |    6 +-
 drivers/net/e1000/e1000_main.c                 |   10 +-
 drivers/net/e1000e/82571.c                     |    4 +-
 drivers/net/e1000e/Makefile                    |    2 +-
 drivers/net/e1000e/defines.h                   |    2 +-
 drivers/net/e1000e/e1000.h                     |    2 +-
 drivers/net/e1000e/es2lan.c                    |    2 +-
 drivers/net/e1000e/ethtool.c                   |    2 +-
 drivers/net/e1000e/hw.h                        |    4 +-
 drivers/net/e1000e/ich8lan.c                   |    2 +-
 drivers/net/e1000e/lib.c                       |   20 +-
 drivers/net/e1000e/netdev.c                    |  223 +++++++++-------=
--
 drivers/net/e1000e/param.c                     |    6 +-
 drivers/net/e1000e/phy.c                       |    4 +-
 drivers/net/gianfar.c                          |   10 +-
 drivers/net/gianfar.h                          |   10 +
 drivers/net/greth.c                            |  221 +++++++++++-----=
---
 drivers/net/greth.h                            |    2 +
 drivers/net/ixgbe/ixgbe_main.c                 |   23 ++-
 drivers/net/macvtap.c                          |    2 +-
 drivers/net/r8169.c                            |   43 +++-
 drivers/net/sfc/efx.c                          |   18 +-
 drivers/net/sfc/net_driver.h                   |   10 +-
 drivers/net/tile/tilepro.c                     |   10 +-
 drivers/net/ucc_geth.c                         |    2 +-
 drivers/net/usb/cdc_ncm.c                      |    4 +-
 drivers/net/vxge/vxge-main.c                   |    1 +
 drivers/net/wireless/ath/ath9k/ar9002_calib.c  |    3 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |    4 +
 drivers/net/wireless/ath/ath9k/htc.h           |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |   37 +++-
 drivers/net/wireless/ath/ath9k/hw.c            |    5 +-
 drivers/net/wireless/hostap/hostap_cs.c        |   15 +-
 drivers/net/wireless/ipw2x00/ipw2200.c         |    7 +
 drivers/net/wireless/p54/txrx.c                |    2 +-
 drivers/ssb/scan.c                             |   10 +
 drivers/vhost/vhost.c                          |   18 +-
 include/linux/etherdevice.h                    |   11 +
 include/linux/netdevice.h                      |    5 -
 include/linux/nl80211.h                        |   20 ++-
 include/linux/skbuff.h                         |   15 ++
 include/net/ah.h                               |    2 +-
 include/net/cfg80211.h                         |    2 +
 include/net/mac80211.h                         |   14 ++
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |   10 -
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |   10 +
 include/net/red.h                              |    1 -
 net/ax25/af_ax25.c                             |    2 +-
 net/core/dev.c                                 |   29 ---
 net/core/skbuff.c                              |    2 +
 net/ethernet/eth.c                             |    2 +-
 net/ipv6/ip6_output.c                          |    3 +
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |    8 +-
 net/netfilter/nf_conntrack_netlink.c           |    3 +-
 net/sched/sch_teql.c                           |   26 ++-
 59 files changed, 655 insertions(+), 576 deletions(-)
