From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-05-06
Date: Wed, 06 May 2015 15:59:40 +0200
Message-ID: <1430920780.1954.10.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57803 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbbEFN7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 09:59:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is the first -next pull request for my mac80211-next tree. See
below for what's in it - there isn't that much.

Please let me know if there are any issues.

johannes




The following changes since commit 388f997620cb57372c494a194e9698b28cc179b8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-04-17 16:31:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-05-06

for you to fetch changes up to 06f207fc541862ba8902ceda0ddeade6ea6bce72:

  cfg80211: change GO_CONCURRENT to IR_CONCURRENT for STA (2015-05-06 15:50:02 +0200)

----------------------------------------------------------------
Lots of updates for net-next for this cycle. As usual, we have
a lot of small fixes and cleanups, the bigger items are:
 * proper mac80211 rate control locking, to fix some random crashes
   (this required changing other locking as well)
 * mac80211 "fast-xmit", a mechanism to reduce, in most cases, the
   amount of code we execute while going from ndo_start_xmit() to
   the driver
 * this also clears the way for properly supporting S/G and checksum
   and segmentation offloads

----------------------------------------------------------------
Arik Nemtsov (1):
      cfg80211: change GO_CONCURRENT to IR_CONCURRENT for STA

Avraham Stern (1):
      cfg80211: Allow GO concurrent relaxation after BSS disconnection

Bob Copeland (1):
      mac80211: introduce plink lock for plink fields

Chaya Rachel Ivgi (1):
      mac80211: fix ignored HT/VHT override configs

Chun-Yeow Yeoh (1):
      cfg80211: allow the plink state blocking for user managed mesh

Emmanuel Grumbach (3):
      iwlwifi: dvm: don't sleep in event_callback callback
      mac80211: notify the driver upon BAR Rx
      mac80211: notify the driver on reordering buffer timeout

Ilan Peer (2):
      mac80211_hwsim: Set VHT capabilities only for the 5.2 GHz band
      mac80211_hwsim: Fix the supported VHT mcs rates

Johannes Berg (28):
      mac80211: lock rate control
      mac80211: add TX fastpath
      mac80211_hwsim: enable IEEE80211_HW_SUPPORT_FAST_XMIT
      mac80211: extend fast-xmit to driver fragmentation
      mac80211: extend fast-xmit for more ciphers
      mac80211: extend fast-xmit to cover IBSS
      wlcore: enable IEEE80211_HW_SUPPORT_FAST_XMIT
      ath10k: enable IEEE80211_HW_SUPPORT_FAST_XMIT
      mac80211: allow checksum offload only in fast-xmit
      mac80211: allow drivers to support S/G
      mac80211: allow segmentation offloads
      mac80211: make station hash table max_size configurable
      mac80211: remove support for IFF_PROMISC
      mac80211: remove IEEE80211_RX_RA_MATCH
      mac80211: clean up/rename prepare_for_handlers()
      mac80211: OCB: remove pointless check for broadcast BSSID
      mac80211: don't update dev->trans_start
      mac80211: use per-CPU TX/RX statistics
      mac80211: clean up global debugfs statistics
      mac80211: move dot11 counters under MAC80211_DEBUG_COUNTERS
      mac80211: remove sta->tx_fragments counter
      mac80211: clean up station debugfs
      mac80211: make LED trigger names const
      mac80211: make LED triggering depend on activation
      mac80211: remove useless skb->encapsulation check
      mac80211: extend get_tkip_seq to all keys
      mac80211: extend get_key() to return PN for all ciphers
      mac80211: validate cipher scheme PN length better

Jonathan Corbet (1):
      mac80211: Fix mac80211.h docbook comments

Matti Gottlieb (1):
      mac80211: force off channel transmission for public action frames

 drivers/net/wireless/adm8211.c                     |   7 +-
 drivers/net/wireless/at76c50x-usb.h                |   2 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |   3 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   7 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   1 -
 drivers/net/wireless/ath/ath5k/led.c               |   2 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |  16 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   9 +-
 drivers/net/wireless/ath/ath9k/main.c              |   3 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   5 -
 drivers/net/wireless/ath/carl9170/fw.c             |   3 +-
 drivers/net/wireless/ath/carl9170/led.c            |   2 +-
 drivers/net/wireless/ath/carl9170/main.c           |   7 +-
 drivers/net/wireless/b43/main.c                    |   8 +-
 drivers/net/wireless/b43legacy/main.c              |   8 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   5 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   2 +-
 drivers/net/wireless/cw1200/sta.c                  |  10 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   4 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   4 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   8 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   2 +-
 drivers/net/wireless/libertas_tf/main.c            |   7 +-
 drivers/net/wireless/mac80211_hwsim.c              |  55 ++-
 drivers/net/wireless/mwl8k.c                       |   2 +-
 drivers/net/wireless/p54/fwio.c                    |   3 +-
 drivers/net/wireless/p54/led.c                     |   2 +-
 drivers/net/wireless/p54/main.c                    |   6 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  19 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |   5 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2800soc.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   6 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   4 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   4 +-
 drivers/net/wireless/rtlwifi/core.h                |   3 +-
 drivers/net/wireless/ti/wl1251/main.c              |   9 +-
 drivers/net/wireless/ti/wlcore/main.c              |   6 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   4 +-
 drivers/staging/vt6655/device_main.c               |  11 +-
 drivers/staging/vt6656/main_usb.c                  |  11 +-
 include/net/cfg80211.h                             |   4 +-
 include/net/mac80211.h                             | 161 ++++---
 include/uapi/linux/nl80211.h                       |  28 +-
 net/mac80211/Kconfig                               |  16 +-
 net/mac80211/cfg.c                                 | 117 +++--
 net/mac80211/chan.c                                |   6 +
 net/mac80211/debugfs.c                             |  74 +--
 net/mac80211/debugfs_sta.c                         |  85 ----
 net/mac80211/driver-ops.h                          |  11 +-
 net/mac80211/ethtool.c                             |   3 +-
 net/mac80211/ieee80211_i.h                         |  35 +-
 net/mac80211/iface.c                               |  64 ++-
 net/mac80211/key.c                                 |  12 +-
 net/mac80211/key.h                                 |   3 +-
 net/mac80211/led.c                                 | 256 ++++++----
 net/mac80211/led.h                                 |  44 +-
 net/mac80211/main.c                                |  15 +-
 net/mac80211/mesh_plink.c                          |  37 +-
 net/mac80211/mlme.c                                |  57 ++-
 net/mac80211/rate.c                                |   8 +-
 net/mac80211/rate.h                                |  14 +-
 net/mac80211/rx.c                                  | 201 ++++----
 net/mac80211/sta_info.c                            |  10 +-
 net/mac80211/sta_info.h                            |  39 +-
 net/mac80211/status.c                              |  28 +-
 net/mac80211/trace.h                               |  42 +-
 net/mac80211/tx.c                                  | 528 ++++++++++++++++++++-
 net/wireless/chan.c                                |  65 ++-
 net/wireless/nl80211.c                             |   7 +-
 net/wireless/reg.c                                 |   4 +-
 76 files changed, 1427 insertions(+), 843 deletions(-)
