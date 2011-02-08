From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-02-08
Date: Tue, 8 Feb 2011 15:41:39 -0500
Message-ID: <20110208204139.GC6244@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55533 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755792Ab1BHUp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 15:45:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest round of wireless bits intended for 2.6.39.
This is mostly driver updates (as usual), including a flurry of
wl1251 patches from David Gnedt.  ath5k, ath9k, and iwlwifi are
well represented, of course.  Interestingly, this batch includes a
number of mac80211 patches -- most of them _not_ from Johannes Berg!
I doubt if that holds for long... :-)  And, zd1211rw grows AP support.
Also, this includes a wireless-2.6 pull to resolve some merge conflicts.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 2360d2e8f01043632d6b651672bec66c49892f94:

  enic: Update MAINTAINERS (2011-02-07 11:49:04 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Arik Nemtsov (3):
      mac80211: do not calc frame duration when using HW rate-control
      mac80211: add HW flag for disabling auto link-PS in AP mode
      mac80211: pass up beacons from external BSS when operating as AP

Ben Greear (7):
      mac80211: Be more careful when changing channels.
      mac80211: Show configured channel-type in netdev debugfs.
      mac80211: Warn users if HT fails because of freq mismatch.
      ath9k: Show channel type and frequency in debugfs.
      mac80211: Recalculate channel-type on iface removal.
      mac80211: Optimize scans on current operating channel.
      mac80211: Make some mlme timers module paramaters.

Christian Lamparter (1):
      mac80211: fix race between next beacon dtim and ieee80211_get_buffered_bc

Dan Carpenter (1):
      mac80211: remove unneeded check

David Gnedt (6):
      wl1251: fix queue stopping/waking for TX path
      wl1251: fix 4-byte TX buffer alignment
      wl1251: enable beacon early termination while in power-saving mode
      wl1251: implement connection quality monitoring
      wl1251: enable adhoc mode
      wl1251: set rate index and preamble flag on received packets

Felix Fietkau (3):
      mac80211: do not send duplicate data frames to the cooked monitor interface
      ath9k: add additional checks for the baseband hang detection
      mac80211: as a 4-addr station, do not receive packets for other stations

Johannes Berg (6):
      iwlwifi: support RSN IBSS
      iwlwifi: advertise max aggregate size
      iwlwifi: use maximum aggregation size
      iwlwifi: fix beacon notification parsing
      mac80211: allow GO to scan like AP
      iwlwifi: remove unnecessary locking

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6

Jouni Malinen (3):
      mac80211: Remove obsolete TKIP flexibility
      mac80211: Add testing functionality for TKIP
      ath: Fix clearing of secondary key cache entry for TKIP

Jussi Kivilinna (21):
      zd1211rw: use urb anchors for tx and fix tx-queue disabling
      zd1211rw: cancel process_intr work on zd_chip_disable_int()
      zd1211rw: add locking for mac->process_intr
      zd1211rw: fix beacon interval setup
      zd1211rw: move set_multicast_hash and set_rx_filter from workers to configure_filter
      zd1211rw: move set_rts_cts_work to bss_info_changed
      zd1211rw: support setting BSSID for AP mode
      zd1211rw: fix ack_pending in filter_ack causing tx-packet ordering problem on monitor
      zd1211rw: let zd_set_beacon_interval() set dtim_period and add AP-beacon flag
      zd1211rw: implement beacon fetching and handling ieee80211_get_buffered_bc()
      zd1211rw: add beacon watchdog and setting HW beacon more failsafe
      zd1211rw: batch beacon config commands together
      zd1211rw: use stack and preallocated memory for small cmd-buffers
      zd1211rw: change interrupt URB buffer to DMA buffer
      zd1211rw: lower hw command timeouts
      zd1211rw: collect driver settings and add function to restore theim
      zd1211rw: add TX watchdog and device resetting
      zd1211rw: reset device when CR_BCN_FIFO_SEMAPHORE freezes in beacon setup
      zd1211rw: reset rx urbs after idle period of 30 seconds
      zd1211rw: enable NL80211_IFTYPE_AP
      zd1211rw: add useful debug output

Justin P. Mattock (1):
      drivers:net:ipw2100.c change a typo comamnd to command

Juuso Oikarinen (1):
      cfg80211: Fix power save state after interface type change

Mohammed Shafi Shajakhan (3):
      ath9k: Fix memory leak due to failed PAPRD frames
      mac80211: Update comments on radiotap MCS index
      ath9k: Update comments for not parsing DTIM period

Nick Kossifidis (1):
      ath5k: Fix fast channel switching

Rajkumar Manoharan (7):
      ath9k_htc: cancel ani work in ath9k_htc_stop
      ath9k: use common get current channel function
      ath9k: move update tx power to common
      ath9k_htc: make use common of function to update txpower
      ath9k: do not access hw registers in FULL SLEEP
      ath9k: reserve a beacon slot on beaconing vif addition
      mac80211: do not restart ps timer during scan or offchannel

Vasily Khoruzhick (2):
      libertas_spi: Use workqueue in hw_host_to_card
      libertas: Prepare stuff for if_spi.c pm support

Wey-Yi Guy (8):
      iwlwifi: check ucode loading error and restart
      iwlagn: adjust rate table
      iwlagn: add IQ inversion support for 2000 series devices
      iwlwifi: always support idle mode for agn devices
      iwlagn: use 2030 macro for 2030 devices
      iwlagn: remove unsupported BT SCO command
      iiwlagn: remove unused parameter
      iwlwifi: fix compiling error with different configuration

 drivers/net/wireless/ath/ath5k/phy.c          |  142 +++++---
 drivers/net/wireless/ath/ath9k/ath9k.h        |    2 +
 drivers/net/wireless/ath/ath9k/beacon.c       |    5 +-
 drivers/net/wireless/ath/ath9k/common.c       |   11 +
 drivers/net/wireless/ath/ath9k/common.h       |    2 +
 drivers/net/wireless/ath/ath9k/debug.c        |   23 ++-
 drivers/net/wireless/ath/ath9k/htc.h          |    1 -
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c |    3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |   24 +-
 drivers/net/wireless/ath/ath9k/main.c         |   96 +++---
 drivers/net/wireless/ath/key.c                |    5 +-
 drivers/net/wireless/ipw2x00/ipw2100.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl-2000.c       |   16 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c       |   32 ++-
 drivers/net/wireless/iwlwifi/iwl-6000.c       |    3 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c    |   28 --
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |   29 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c  |    8 -
 drivers/net/wireless/iwlwifi/iwl-agn.c        |   87 ++++--
 drivers/net/wireless/iwlwifi/iwl-commands.h   |    8 +-
 drivers/net/wireless/iwlwifi/iwl-core.h       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h        |    2 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |    7 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c      |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   14 +-
 drivers/net/wireless/libertas/cmd.c           |   10 +-
 drivers/net/wireless/libertas/dev.h           |    2 +
 drivers/net/wireless/libertas/if_spi.c        |  368 +++++++++++++-------
 drivers/net/wireless/libertas/main.c          |   77 +++--
 drivers/net/wireless/wl1251/acx.c             |   53 +++
 drivers/net/wireless/wl1251/acx.h             |   72 ++++
 drivers/net/wireless/wl1251/event.c           |   18 +
 drivers/net/wireless/wl1251/main.c            |   18 +-
 drivers/net/wireless/wl1251/ps.c              |   11 +
 drivers/net/wireless/wl1251/rx.c              |   46 +++-
 drivers/net/wireless/wl1251/tx.c              |   74 ++---
 drivers/net/wireless/wl1251/wl1251.h          |    7 +
 drivers/net/wireless/zd1211rw/zd_chip.c       |  134 +++++---
 drivers/net/wireless/zd1211rw/zd_chip.h       |    5 +-
 drivers/net/wireless/zd1211rw/zd_mac.c        |  448 +++++++++++++++++++------
 drivers/net/wireless/zd1211rw/zd_mac.h        |   24 +-
 drivers/net/wireless/zd1211rw/zd_usb.c        |  444 +++++++++++++++++++------
 drivers/net/wireless/zd1211rw/zd_usb.h        |   30 ++-
 include/net/mac80211.h                        |   58 ++++-
 net/mac80211/cfg.c                            |   26 ++-
 net/mac80211/debugfs_netdev.c                 |  108 ++++++-
 net/mac80211/ieee80211_i.h                    |   14 +-
 net/mac80211/iface.c                          |    9 +-
 net/mac80211/main.c                           |   53 +++-
 net/mac80211/mlme.c                           |   60 +++-
 net/mac80211/offchannel.c                     |   68 ++--
 net/mac80211/rx.c                             |   59 +++--
 net/mac80211/scan.c                           |   88 ++++--
 net/mac80211/sta_info.c                       |    3 +-
 net/mac80211/status.c                         |    4 +
 net/mac80211/tx.c                             |   12 +-
 net/mac80211/work.c                           |   66 +++-
 net/mac80211/wpa.c                            |   39 +--
 net/wireless/core.c                           |   20 +-
 61 files changed, 2215 insertions(+), 872 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2011-02-08.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
