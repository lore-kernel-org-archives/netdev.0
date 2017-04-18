From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2017-04-18
Date: Tue, 18 Apr 2017 11:20:29 +0200
Message-ID: <20170418092030.7299-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46550 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755629AbdDRJUf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 05:20:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I hadn't realized that I actually had this many patches pending,
but most of them really are cleanups and little fixes. Despite a
bunch of driver changes, there don't seem to be any conflicts.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 8d70eeb84ab277377c017af6a21d0a337025dede:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-03-04 17:31:39 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-04-18

for you to fetch changes up to bbf67e450a5dc2a595e1e7a67b4869f1a7f5a338:

  nl80211: Fix enum type of variable in nl80211_put_sta_rate() (2017-04-18 11:03:03 +0200)

----------------------------------------------------------------
My last pull request has been a while, we now have:
 * connection quality monitoring with multiple thresholds
 * support for FILS shared key authentication offload
 * pre-CAC regulatory compliance - only ETSI allows this
 * sanity check for some rate confusion that hit ChromeOS
   (but nobody else uses it, evidently)
 * some documentation updates
 * lots of cleanups

----------------------------------------------------------------
Andrew Zaborowski (4):
      cfg80211: Accept multiple RSSI thresholds for CQM
      mac80211: Add set_cqm_rssi_range_config
      wireless: Set NL80211_EXT_FEATURE_CQM_RSSI_LIST in multiple drivers
      mac80211_hwsim: Make sure NEW_RADIO contains final name

Arend Van Spriel (1):
      nl80211: add request id in scheduled scan event messages

Arkadiusz Miskiewicz (1):
      mac80211: Print text for disassociation reason

Avraham Stern (1):
      ieee80211: add FT-PSK AKM suite selector

Ben Greear (1):
      mac80211-hwsim: remove dmesg spam about get-survey.

Johannes Berg (24):
      cfg80211: combine two nested ifs into a single condition
      ieee80211: rename CCFS1/CCFS2 to CCFS0/CCFS1
      mac80211: remove local pointer from rate_ctrl_ref
      cfg80211: refactor cfg80211_calculate_bitrate()
      mac80211: encode rate type (legacy, HT, VHT) with fewer bits
      ieee80211: define HT operation CCFS2 field
      mac80211_hwsim: fix command documentation indentation
      mac80211_hwsim: report survey data for scanned channels
      mac80211: ignore VHT membership selector when parsing rates
      iwlegacy: remove usage of txrc->max_rate_idx
      iwlwifi: dvm: remove usage of txrc->max_rate_idx
      mac80211: remove ieee80211_tx_rate_control.max_rate_idx
      mac80211: reject/clear user rate mask if not usable
      cfg80211: preserve wdev ID across netns changes
      cfg80211: add documentation for cfg80211_get_bss()
      cfg80211: add intro to documentation
      mac80211: drop frames too short for FCS earlier
      cfg80211: allow leaving MU-MIMO monitor configuration unchanged
      mac80211: correct MU-MIMO monitor follow functionality
      cfg80211: move add/change interface monitor flags into params
      cfg80211: refactor nl80211 monitor option parsing
      mac80211: use common code for monitor options in add/change
      mac80211_hwsim: use per-interface power level
      mac80211: keep a separate list of monitor interfaces that are up

Jouni Malinen (1):
      mac80211_hwsim: Add channel 169 (5845 MHz)

Manoharan, Rajkumar (2):
      mac80211: use DECLARE_EWMA for mesh_fail_avg
      mac80211: fix mesh fail_avg check

Masashi Honma (2):
      nl80211: Use signed function for a signed variable
      mac80211: mesh: drop new node with weak power

Matthias Kaehlcke (4):
      mac80211: Fix clang warning about constant operand in logical operation
      cfg80211: Fix array-bounds warning in fragment copy
      mac80211: ibss: Fix channel type enum in ieee80211_sta_join_ibss()
      nl80211: Fix enum type of variable in nl80211_put_sta_rate()

Ondřej Lysoněk (2):
      mac80211: Use setup_timer instead of init_timer
      mac80211: Use setup_timer instead of init_timer for mesh path

Vasanthakumar Thiagarajan (3):
      cfg80211: Make pre-CAC results valid only for ETSI domain
      cfg80211: Disallow moving out of operating DFS channel in non-ETSI
      cfg80211: Share Channel DFS state across wiphys of same DFS domain

Vidyullatha Kanchanapally (2):
      cfg80211: Use a structure to pass connect response params
      cfg80211: Add support for FILS shared key authentication offload

 Documentation/driver-api/80211/cfg80211.rst        |   9 +
 drivers/net/wireless/admtek/adm8211.c              |   2 +
 drivers/net/wireless/ath/ar5523/ar5523.c           |   2 +
 drivers/net/wireless/ath/ath10k/mac.c              |   2 +
 drivers/net/wireless/ath/ath5k/base.c              |   2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   2 +
 drivers/net/wireless/ath/ath9k/init.c              |   2 +
 drivers/net/wireless/ath/carl9170/main.c           |   2 +
 drivers/net/wireless/ath/wcn36xx/main.c            |   3 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  14 +-
 drivers/net/wireless/atmel/at76c50x-usb.c          |   2 +
 drivers/net/wireless/broadcom/b43/main.c           |   2 +
 drivers/net/wireless/broadcom/b43legacy/main.c     |   2 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  12 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   3 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.h |   2 +-
 .../broadcom/brcm80211/brcmsmac/mac80211_if.c      |   2 +
 drivers/net/wireless/intel/iwlegacy/3945-mac.c     |   2 +
 drivers/net/wireless/intel/iwlegacy/3945-rs.c      |   2 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |   2 +
 drivers/net/wireless/intel/iwlegacy/4965-rs.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |   2 +
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |   2 +-
 drivers/net/wireless/intersil/orinoco/cfg.c        |   2 +-
 drivers/net/wireless/mac80211_hwsim.c              |  90 +++-
 drivers/net/wireless/mac80211_hwsim.h              |   4 +-
 drivers/net/wireless/marvell/libertas/cfg.c        |   2 +-
 drivers/net/wireless/marvell/libertas_tf/main.c    |   2 +
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |  27 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |   7 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |   1 -
 drivers/net/wireless/marvell/mwifiex/tdls.c        |   2 +-
 drivers/net/wireless/marvell/mwl8k.c               |   2 +
 drivers/net/wireless/mediatek/mt7601u/init.c       |   2 +
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |   3 +
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |   2 +
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c |   2 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |   2 +
 drivers/net/wireless/rndis_wlan.c                  |   4 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |   2 +
 drivers/net/wireless/zydas/zd1211rw/zd_mac.c       |   2 +
 drivers/staging/wilc1000/wilc_wfi_cfgoperations.c  |   3 +-
 drivers/staging/wlan-ng/cfg80211.c                 |   2 +-
 include/linux/ieee80211.h                          |  20 +-
 include/net/cfg80211.h                             | 192 ++++++++-
 include/net/mac80211.h                             |  10 +-
 include/uapi/linux/nl80211.h                       | 100 ++++-
 net/mac80211/agg-rx.c                              |  12 +-
 net/mac80211/agg-tx.c                              |  12 +-
 net/mac80211/cfg.c                                 | 203 ++++++---
 net/mac80211/ibss.c                                |   4 +-
 net/mac80211/ieee80211_i.h                         |   3 +
 net/mac80211/iface.c                               |  19 +-
 net/mac80211/main.c                                |   1 +
 net/mac80211/mesh.c                                |  10 +-
 net/mac80211/mesh_hwmp.c                           |  23 +-
 net/mac80211/mesh_pathtbl.c                        |   8 +-
 net/mac80211/mlme.c                                |  41 +-
 net/mac80211/rate.c                                |  43 +-
 net/mac80211/rate.h                                |   3 +-
 net/mac80211/rx.c                                  |  50 +--
 net/mac80211/spectmgmt.c                           |   4 +-
 net/mac80211/sta_info.c                            |  11 +-
 net/mac80211/sta_info.h                            |  18 +-
 net/mac80211/tx.c                                  |   8 -
 net/mac80211/util.c                                |  22 +-
 net/wireless/ap.c                                  |   5 +
 net/wireless/chan.c                                | 117 ++++++
 net/wireless/core.c                                |  68 ++-
 net/wireless/core.h                                |  47 ++-
 net/wireless/ibss.c                                |   1 +
 net/wireless/mesh.c                                |   1 +
 net/wireless/mlme.c                                |  70 +++-
 net/wireless/nl80211.c                             | 465 ++++++++++++++++-----
 net/wireless/nl80211.h                             |  10 +-
 net/wireless/rdev-ops.h                            |  21 +-
 net/wireless/reg.c                                 | 148 +++++++
 net/wireless/reg.h                                 |  36 ++
 net/wireless/scan.c                                |   5 +-
 net/wireless/sme.c                                 | 172 +++++---
 net/wireless/trace.h                               |  22 +
 net/wireless/util.c                                |  92 ++--
 net/wireless/wext-compat.c                         |   2 +-
 84 files changed, 1802 insertions(+), 540 deletions(-)
