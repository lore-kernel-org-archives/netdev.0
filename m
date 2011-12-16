From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 16 Dec 2011 15:15:46 -0500 (EST)
Message-ID: <20111216.151546.484944628207787223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932637Ab1LPUPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:15:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) IPv6 code checks prefix length of destination address on wrong route, so
   anycast handling is never performed.

2) Device name handling in ipip/sit regressed, copy the name into the device
   parms after register_netdevice() to fix it.  From Ted Feng.

3) Add device ID to btmrvl bluetooth driver, from Bing Zhao.

4) Fix module refcounting in bluetooth cmtp and bnep modules, from
   David Herrmann.

5) Leak fix in btusb_send_frame(), from Cong Wang.

6) hci_setup() checks the wrong version field in device structure, fix from
   Andrei Emeltchenko.

7) Roaming clients fixes in batman-adv from Antonio Quartulli.

8) Fix regression on single-stream ath9k wireless chips by properly testing
   for antenna diversity support, from Felix Fietkau.

9) pptp module double releases socket in bind() error path, from Djalal Harouni.

10) Fix races in wireless TX aggregation start, from Jahannes Berg.

11) Fix SSB bus initialization regression causing data bus errors, from
    Hauke Mehrtens.

12) IPV6 erroneously adds a multicast route on the loopback device when it
    is brought up, this can cause multicast communication failures depending
    upon the order in which devices are brought up.  From Li Wei.

13) Use GFP_ATOMIC while holding lock in GRED packet scheduler, fix from Eric
    Dumazet.

Please pull, thanks a lot!

The following changes since commit 2cfab8d74ebfbe06ce2947117945c4f45a5915ec:

  Merge branch 'drm-intel-fixes' of git://people.freedesktop.org/~keithp/linux (2011-12-16 11:27:56 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andrei Emeltchenko (1):
      Bluetooth: Correct version check in hci_setup

Andy Fleming (1):
      fsl_pq_mdio: Clean up tbi address configuration

Antonio Quartulli (2):
      batman-adv: in case of roaming mark the client with TT_CLIENT_ROAM
      batman-adv: delete global entry in case of roaming

Bing Zhao (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8797

Cong Wang (1):
      btusb: fix a memory leak in btusb_send_frame()

David Herrmann (2):
      Bluetooth: cmtp: Fix module reference
      Bluetooth: bnep: Fix module reference

David S. Miller (2):
      Merge branch 'batman-adv/maint' of git://git.open-mesh.org/linux-merge
      ipv6: Check dest prefix length on original route not copied one in rt6_alloc_cow().

Djalal Harouni (1):
      ppp: fix pptp double release_sock in pptp_bind()

Eric Dumazet (1):
      sch_gred: should not use GFP_KERNEL while holding a spinlock

Felix Fietkau (1):
      ath9k: fix check for antenna diversity support

Hauke Mehrtens (1):
      ssb: fix init regression with SoCs

Johannes Berg (1):
      mac80211: fix another race in aggregation start

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Li Wei (1):
      ipv6: Fix for adding multicast route for loopback device automatically.

Philipp Dreimann (1):
      rtl8192{ce,cu,de,se}: avoid problems because of possible ERFOFF -> ERFSLEEP transition

Shawn Guo (1):
      net/fec: fix the use of pdev->id

Ted Feng (1):
      ipip, sit: copy parms.name after register_netdevice

 drivers/bluetooth/Kconfig                    |    6 +-
 drivers/bluetooth/btmrvl_sdio.c              |   15 ++++-
 drivers/bluetooth/btusb.c                    |    3 +-
 drivers/net/ethernet/freescale/fec.c         |   11 ++-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   53 +++-------------
 drivers/net/ppp/pptp.c                       |    4 +-
 drivers/net/wireless/ath/ath9k/main.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c |    2 +-
 drivers/ssb/driver_pcicore.c                 |    8 ++-
 net/batman-adv/translation-table.c           |   27 +++++++--
 net/bluetooth/bnep/core.c                    |    8 +--
 net/bluetooth/cmtp/core.c                    |    5 +-
 net/bluetooth/hci_event.c                    |    2 +-
 net/ipv4/ipip.c                              |    7 ++-
 net/ipv6/addrconf.c                          |    3 +-
 net/ipv6/route.c                             |    2 +-
 net/ipv6/sit.c                               |    7 ++-
 net/mac80211/agg-tx.c                        |   86 ++++++++++++-------------
 net/sched/sch_gred.c                         |    2 +-
 22 files changed, 130 insertions(+), 129 deletions(-)
