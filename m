From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2017-04-28
Date: Fri, 28 Apr 2017 19:56:57 +0200
Message-ID: <20170428175658.1961-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55068 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968959AbdD1R5E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 13:57:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Since I had many API changes pending I decided to go ahead and
take the opportunity to get them before the merge window, which
is a natural tree synchronization point :)

I meant to sent this earlier today but forgot due to some debug
(unrelated to this code, in our internal tree), sorry about that.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 5e1fc7c5ba00599ccd7096eef3e9fd3362c1230f:

  drivers: net: xgene-v2: Fix error return code in xge_mdio_config() (2017-04-25 13:48:06 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-04-28

for you to fetch changes up to b34939b9836950d261610132853311054b507247:

  cfg80211: add request id to cfg80211_sched_scan_*() api (2017-04-28 14:51:43 +0200)

----------------------------------------------------------------
Another set of patches for -next:
 * API support for concurrent scheduled scan requests
 * API changes for roaming reporting
 * BSS max idle support in mac80211
 * API changes for TX status reporting in mac80211
 * API changes for RX rate reporting in mac80211
 * rewrite monitor logic to prepare for BPF filters
 * bugfix for rare devices without 2.4 GHz support
 * a bugfix for recent DFS changes
 * some further cleanups

The API changes are actually at a nice time, since it's
typically quiet just before the merge window, and trees
can be synchronized easily during it.

----------------------------------------------------------------
Arend Van Spriel (4):
      nl80211: allow multiple active scheduled scan requests
      nl80211: add support for BSSIDs in scheduled scan matchsets
      cfg80211: add request id parameter to .sched_scan_stop() signature
      cfg80211: add request id to cfg80211_sched_scan_*() api

Avraham Stern (2):
      cfg80211: unify cfg80211_roamed() and cfg80211_roamed_bss()
      mac80211: Add support for BSS max idle period element

Emmanuel Grumbach (1):
      mac80211: don't parse encrypted management frames in ieee80211_frame_acked

Felix Fietkau (3):
      mac80211: make rate control tx status API more extensible
      mac80211: move ieee80211_tx_status_noskb below ieee80211_tx_status
      mac80211: add ieee80211_tx_status_ext

Johannes Berg (8):
      mac80211: rewrite monitor mode delivery logic
      cfg80211: simplify netlink socket owner interface deletion
      ieee80211: fix kernel-doc parsing errors
      mac80211: disentangle iflist_mtx and chanctx_mtx
      mac80211: clean up rate encoding bits in RX status
      mac80211: separate encoding/bandwidth from flags
      mac80211: rename ieee80211_rx_status::vht_nss to just nss
      mac80211: use bitfield macros for encoded rate

Luca Coelho (3):
      ieee80211: add SUITE_B AKM selectors
      ieee80211: add FT-802.1X AKM suite selector
      mac80211: make multicast variable a bool in ieee80211_accept_frame()

Mohammed Shafi Shajakhan (1):
      mac80211: Fix possible sband related NULL pointer de-reference

Vasanthakumar Thiagarajan (1):
      cfg80211: Fix dfs state propagation for non-DFS center channel

 drivers/net/wireless/ath/ath10k/htt_rx.c           |  48 ++---
 drivers/net/wireless/ath/ath5k/base.c              |   6 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  16 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   7 +-
 drivers/net/wireless/ath/ath9k/common.c            |  11 +-
 drivers/net/wireless/ath/ath9k/debug_sta.c         |   6 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   7 +-
 drivers/net/wireless/ath/ath9k/mac.c               |  15 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   4 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   8 +-
 drivers/net/wireless/ath/carl9170/rx.c             |   8 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c            |   2 +-
 drivers/net/wireless/broadcom/b43/xmit.c           |   2 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  25 ++-
 .../wireless/broadcom/brcm80211/brcmsmac/main.c    |  10 +-
 drivers/net/wireless/intel/iwlegacy/3945.c         |   2 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |   8 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c        |  10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |  26 +--
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  26 +--
 drivers/net/wireless/intersil/p54/txrx.c           |   2 +-
 drivers/net/wireless/mac80211_hwsim.c              |  10 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |  10 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |   2 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   2 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |   2 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |   2 +-
 drivers/net/wireless/marvell/mwl8k.c               |  16 +-
 drivers/net/wireless/mediatek/mt7601u/mac.c        |  12 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   4 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |   5 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.h   |   3 +
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |   2 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c |   2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |  10 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.c   |   8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   |  12 +-
 drivers/net/wireless/rndis_wlan.c                  |  19 +-
 drivers/net/wireless/st/cw1200/txrx.c              |   2 +-
 drivers/net/wireless/ti/wl1251/rx.c                |   2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   2 +-
 drivers/net/wireless/ti/wlcore/rx.c                |   2 +-
 drivers/staging/wlan-ng/cfg80211.c                 |   7 +-
 include/linux/ieee80211.h                          |  67 ++++--
 include/net/cfg80211.h                             | 105 +++++----
 include/net/mac80211.h                             | 172 +++++++++------
 include/uapi/linux/nl80211.h                       |  16 +-
 net/mac80211/cfg.c                                 |  39 ++--
 net/mac80211/ibss.c                                |  10 +-
 net/mac80211/ieee80211_i.h                         |  41 ++--
 net/mac80211/main.c                                |   2 +
 net/mac80211/mesh.c                                |  29 ++-
 net/mac80211/mesh_plink.c                          |  37 +++-
 net/mac80211/mlme.c                                |  28 ++-
 net/mac80211/pm.c                                  |   2 +-
 net/mac80211/rate.c                                |  26 ++-
 net/mac80211/rate.h                                |  44 +---
 net/mac80211/rc80211_minstrel.c                    |   6 +-
 net/mac80211/rc80211_minstrel_ht.c                 |  10 +-
 net/mac80211/rx.c                                  | 234 ++++++++++++---------
 net/mac80211/scan.c                                |  12 +-
 net/mac80211/sta_info.c                            |  39 ++--
 net/mac80211/sta_info.h                            |  83 +++++---
 net/mac80211/status.c                              | 168 ++++++++-------
 net/mac80211/tdls.c                                |  29 ++-
 net/mac80211/tx.c                                  |   5 +-
 net/mac80211/util.c                                |  79 ++++---
 net/wireless/core.c                                |  57 ++---
 net/wireless/core.h                                |  35 ++-
 net/wireless/nl80211.c                             | 143 ++++++++-----
 net/wireless/nl80211.h                             |   5 +-
 net/wireless/rdev-ops.h                            |   8 +-
 net/wireless/reg.c                                 |   3 -
 net/wireless/scan.c                                | 160 ++++++++++----
 net/wireless/sme.c                                 |  90 ++++----
 net/wireless/trace.h                               |  54 +++--
 net/wireless/util.c                                |   4 +-
 86 files changed, 1323 insertions(+), 936 deletions(-)
