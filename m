From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 30 Jul 2008 04:45:05 -0700 (PDT)
Message-ID: <20080730.044505.71192524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50601
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753102AbYG3LpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 07:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This should fix several networking issues that have been
either recently reported or in the background being worked
on since the TX multiqueue stuff went in:

1) Wireless merge from John Linville and co.  Included, among other
   things, is a fix for mac80211 based devices.  The mac80211 stack
   was assuming that the skb CB went unchanged as the packet went
   through the QDISC layer, but that has never been true.

   Fix from Johannes Berg.

2) Kill annoying messages when TCP MD5 packets arrive and
   the listening socket does not have MD5 enabled, and vice
   versa.  Use a MIB statistic counter instead.  Based upon
   a report by Matti Aarnio and initial patch by Adam L.

3) Ingress qdiscs were broken by TX multiqueue changes, causing
   OOPS, fixed by me.

The only remaining significant regression from the TX multiqueue bits
is a harmless lockdep warning, and I'm working on a fix for that.

Please pull, thanks a lot!

The following changes since commit 6e86841d05f371b5b9b86ce76c02aaee83352298:
  Linus Torvalds (1):
        Linux 2.6.27-rc1

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andreas Schwab (1):
      niu: Fix error checking in niu_ethflow_to_class.

Andrew Morton (1):
      drivers/net/wireless/iwlwifi/iwl-led.c: printk fix

Bob Copeland (2):
      ath5k: use positive logic for HP laptop LEDs
      ath5k: fix recursive locking in ath5k_beacon_update

Brian Cavagnolo (1):
      libertas: check bounds and only use decimal for sysfs persistent features.

Daniel Lezcano (1):
      ipv6: Fix useless proc net sockstat6 removal

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      pkt_sched: Fix OOPS on ingress qdisc add.
      tcp: MD5: Use MIB counter instead of warning for MD5 mismatch.

Denis V. Lunev (2):
      iwlwifi: compilation error when CONFIG_IWLWIFI_DEBUG is not set
      iwlwifi: small compile warnings without CONFIG_IWLWIFI_DEBUG

Harvey Harrison (1):
      mac80211: fix sparse integer as NULL pointer warning

Henrique de Moraes Holschuh (5):
      rfkill: document rfkill_force_state as required (v2)
      rfkill: fix led-trigger unregister order in error unwind
      rfkill: document the rfkill struct locking (v2)
      rfkill: mutex fixes
      rfkill: yet more minor kernel-doc fixes

Ivo van Doorn (6):
      rt2x00: Remove duplicate declaration
      rt2x00: Fix EIFS timing value
      rt2x00: Fix QOS sequence counting
      rt2x00: Fix memleak when RTS/CTS fails
      rt2x00: Force full register config after start()
      rt2x00: Clear queue entry flags during initialization

Iwo Mergler (3):
      rt2x00: Support for large vendor requests
      rt2x00: Large vendor requests for rt73usb firmware upload and beacons
      rt2x00: Fix the beacon length bug

Jeremy Fitzhardinge (1):
      mac80211: return correct error return from ieee80211_wep_init

Jiri Slaby (6):
      Ath5k: fix memory corruption
      Ath5k: kill tasklets on shutdown
      Ath5k: flush work
      Ath5k: fix dma operation
      Ath5k: suspend/resume fixes
      mac80211: tx, use dev_kfree_skb_any for beacon_get

Johannes Berg (4):
      mac80211: remove IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE flag
      mac80211: partially fix skb->cb use
      nl80211: fix dump callbacks
      mac80211: fix cfg80211 hooks for master interface

Julia Lawall (2):
      drivers/net/wireless/ipw2100.c: Release mutex in error handling code
      b43legacy: Release mutex in error handling code

Larry Finger (2):
      rtl8187: Fix for TX sequence number problem
      rtl8187: Improve wireless statistics for RTL8187B

Luis Carlos Cobo (1):
      mac80211: fix mesh beaconing

Miao Xie (1):
      IPv6: datagram_send_ctl() should exit immediately when an error occured

Pavel Roskin (1):
      ath5k: don't enable MSI, we cannot handle it yet

Rami Rosen (2):
      iwl-3945: add #ifdef CONFIG_IWL3945_LEDS to avoid compile warning.
      mac80211: append CONFIG_ to MAC80211_VERBOSE_PS_DEBUG in net/mac80211/tx.c.

Robert P. J. Day (1):
      net: Make "networking" one-click deselectable.

Vegard Nossum (1):
      PS3: gelic: use unsigned long for irqflags

 Documentation/rfkill.txt                    |   20 ++-
 drivers/net/niu.c                           |    2 +-
 drivers/net/ps3_gelic_wireless.c            |   12 +-
 drivers/net/wireless/ath5k/base.c           |   99 ++++++----
 drivers/net/wireless/ath5k/base.h           |    2 +-
 drivers/net/wireless/ath5k/hw.c             |    4 +
 drivers/net/wireless/b43/main.c             |    3 +-
 drivers/net/wireless/b43/xmit.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    5 +-
 drivers/net/wireless/b43legacy/xmit.c       |    2 +-
 drivers/net/wireless/ipw2100.c              |    3 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |    8 +-
 drivers/net/wireless/iwlwifi/iwl-led.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    5 +-
 drivers/net/wireless/libertas/persistcfg.c  |   30 ++--
 drivers/net/wireless/mac80211_hwsim.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |   13 ++-
 drivers/net/wireless/rt2x00/rt2x00.h        |    6 +-
 drivers/net/wireless/rt2x00/rt2x00config.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    7 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    7 -
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   29 ++--
 drivers/net/wireless/rt2x00/rt2x00queue.c   |   36 ++++-
 drivers/net/wireless/rt2x00/rt2x00queue.h   |    2 +
 drivers/net/wireless/rt2x00/rt2x00usb.c     |   32 +++
 drivers/net/wireless/rt2x00/rt2x00usb.h     |   22 ++-
 drivers/net/wireless/rt2x00/rt61pci.c       |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |   56 +++----
 drivers/net/wireless/rtl8187.h              |   11 +-
 drivers/net/wireless/rtl8187_dev.c          |   93 ++++++---
 drivers/net/wireless/zd1211rw/zd_mac.c      |    1 -
 include/linux/rfkill.h                      |    8 +-
 include/linux/skbuff.h                      |    5 +-
 include/linux/snmp.h                        |    2 +
 include/net/mac80211.h                      |    7 -
 net/Kconfig                                 |    7 +-
 net/core/dev.c                              |    4 +-
 net/core/skbuff.c                           |    3 +
 net/ipv4/proc.c                             |    2 +
 net/ipv4/tcp_ipv4.c                         |   10 +-
 net/ipv6/datagram.c                         |    2 +-
 net/ipv6/proc.c                             |    1 -
 net/ipv6/tcp_ipv6.c                         |   27 +--
 net/mac80211/cfg.c                          |  103 +++++++++--
 net/mac80211/main.c                         |   12 +-
 net/mac80211/mlme.c                         |    9 +-
 net/mac80211/tx.c                           |   55 +++---
 net/mac80211/wep.c                          |    4 +-
 net/mac80211/wme.c                          |    3 +
 net/rfkill/rfkill.c                         |   62 ++++---
 net/sched/sch_api.c                         |   57 ++----
 net/sched/sch_generic.c                     |    8 +-
 net/wireless/nl80211.c                      |  277 +++++++++++++++------------
 57 files changed, 714 insertions(+), 487 deletions(-)

