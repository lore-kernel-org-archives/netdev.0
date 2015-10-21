From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-10-21
Date: Wed, 21 Oct 2015 17:07:06 +0200
Message-ID: <1445440026.4558.62.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54646 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918AbbJUPHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 11:07:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here's another, likely final, pull request for -next. I finally caved
in and cleaned up the regulatory code a bit, which is the bulk of the
changes.

There's a new Kconfig which allows turning off CRDA, but it's hidden
behind having the internal regdb enabled, which in turn is hidden
behind EXPERT, so hopefully you won't even see that :) (although I am
hoping to get rid of the internal regdb sooner rather than later)

Let me know if you see any problems.

Thanks,
johannes




The following changes since commit 6623c60dc28ee966cd85c6f12aa2fc3c952d0179:

  bridge: vlan: enforce no pvid flag in vlan ranges (2015-10-12 19:59:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-10-21

for you to fetch changes up to e5a9f8d04660da7ef3a98260aa74c3976f9cb4cd:

  mac80211: move station statistics into sub-structs (2015-10-21 10:08:22 +0200)

----------------------------------------------------------------
Here's another set of patches for the current cycle:
 * I merged net-next back to avoid a conflict with the
 * cfg80211 scheduled scan API extensions
 * preparations for better scan result timestamping
 * regulatory cleanups
 * mac80211 statistics cleanups
 * a few other small cleanups and fixes

----------------------------------------------------------------
Avraham Stern (2):
      cfg80211: Add multiple scan plans for scheduled scan
      mac80211: Do not restart scheduled scan if multiple scan plans are set

Dmitry Shmidt (1):
      nl80211: allow BSS data to include CLOCK_BOOTTIME timestamp

Felix Fietkau (1):
      mac80211: add missing struct ieee80211_txq tid field initialization

Johannes Berg (25):
      Merge remote-tracking branch 'net-next/master' into mac80211-next
      wireless: update robust action frame list
      wireless: add WNM action frame categories
      mac80211: use new cfg80211_inform_bss_frame_data() API
      mac80211: remove PM-QoS listener
      mac80211: clean up ieee80211_rx_h_check_dup code
      mac80211: move sta_set_rate_info_rx() and make it static
      mac80211: remove cfg.h
      mac80211: remove event.c
      cfg80211: fix gHz to GHz
      cfg80211: reg: remove useless non-NULL check
      cfg80211: reg: fix reg_call_crda() return value bug
      cfg80211: reg: rename reg_call_crda to reg_query_database
      cfg80211: reg: search built-in database directly
      cfg80211: reg: remove useless reg_timeout scheduling
      cfg80211: reg: make CRDA support optional
      cfg80211: reg: rename reg_regdb_query() to reg_query_builtin()
      cfg80211: reg: clarify 'treatment' handling in reg_process_hint()
      cfg80211: reg: centralize freeing ignored requests
      cfg80211: reg: fix antenna gain in chan_reg_rule_print_dbg()
      cfg80211: reg: reduce chan_reg_rule_print_dbg() ifdef
      cfg80211: reg: fix reg_ignore_cell_hint return type
      mac80211: remove sta->last_ack_signal
      mac80211: move beacon_loss_count into ifmgd
      mac80211: move station statistics into sub-structs

Tamizh chelvam (1):
      Revert "mac80211: remove exposing 'mfp' to drivers"

 Documentation/DocBook/80211.tmpl           |   5 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c |   2 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c     |   1 +
 drivers/net/wireless/iwlwifi/mvm/scan.c    |   4 +-
 drivers/net/wireless/rt2x00/rt2x00config.c |   2 +-
 drivers/net/wireless/ti/wl12xx/scan.c      |   3 +-
 drivers/net/wireless/ti/wl18xx/scan.c      |   8 +-
 include/linux/ieee80211.h                  |   5 +
 include/net/cfg80211.h                     | 126 ++++++++++---
 include/net/mac80211.h                     |   8 +-
 include/uapi/linux/nl80211.h               |  57 +++++-
 net/mac80211/Makefile                      |   1 -
 net/mac80211/cfg.c                         |  45 +----
 net/mac80211/cfg.h                         |   9 -
 net/mac80211/debugfs_sta.c                 |   8 +-
 net/mac80211/ethtool.c                     |  29 ++-
 net/mac80211/event.c                       |  27 ---
 net/mac80211/ibss.c                        |  24 +--
 net/mac80211/ieee80211_i.h                 |  13 +-
 net/mac80211/iface.c                       |   4 +-
 net/mac80211/main.c                        |  14 --
 net/mac80211/mesh_hwmp.c                   |   2 +-
 net/mac80211/mesh_plink.c                  |   6 +-
 net/mac80211/mlme.c                        |  85 +++------
 net/mac80211/ocb.c                         |   2 +-
 net/mac80211/rx.c                          |  81 ++++----
 net/mac80211/scan.c                        |  20 +-
 net/mac80211/sta_info.c                    | 101 +++++++---
 net/mac80211/sta_info.h                    | 103 ++++------
 net/mac80211/status.c                      |  53 +++---
 net/mac80211/trace.h                       |   2 -
 net/mac80211/tx.c                          |  20 +-
 net/mac80211/util.c                        |  12 +-
 net/mac80211/wpa.c                         |   9 +-
 net/wireless/Kconfig                       |  10 +
 net/wireless/core.c                        |   5 +-
 net/wireless/core.h                        |   1 +
 net/wireless/nl80211.c                     | 288 +++++++++++++++++++++-------
 net/wireless/reg.c                         | 291 ++++++++++++++++-------------
 net/wireless/scan.c                        |  61 +++---
 net/wireless/trace.h                       |  22 +--
 41 files changed, 910 insertions(+), 659 deletions(-)
 delete mode 100644 net/mac80211/cfg.h
 delete mode 100644 net/mac80211/event.c
