From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-01-15
Date: Thu, 15 Jan 2015 13:45:02 +0100
Message-ID: <1421325902.1962.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36148 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbbAOMpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:45:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My first pull request for -next, sorry I dragged my feet on this.

I merged mac80211.git to avoid some conflicts, but the content was in
net-next already anyway.

Let me know if there's any issue or any format changes you'd like to make.

Thanks,
johannes




The following changes since commit 28a9bc68124c319b2b3dc861e80828a8865fd1ba:

  mac80211: free management frame keys when removing station (2014-12-17 14:00:17 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-01-15

for you to fetch changes up to baf1b99ba169bdd3324ac9d99bc2a00c25534429:

  cfg80211: docs: remove station_info_flags (2015-01-14 13:57:36 +0100)

----------------------------------------------------------------
Here's a big pile of changes for this round.

We have
 * a lot of regulatory code changes to deal with the
   way newer Intel devices handle this
 * a change to drop packets while disconnecting from
   an AP instead of trying to wait for them
 * a new attempt at improving the tailroom accounting
   to not kick in too much for performance reasons
 * improvements in wireless link statistics
 * many other small improvements and small fixes that
   didn't seem necessary for 3.19 (e.g. in hwsim which
   is testing only code)

----------------------------------------------------------------

Andrew Clausen (1):
      rfkill: document rfkill module parameters

Arik Nemtsov (8):
      cfg80211: allow usermode to query wiphy specific regdom
      cfg80211: return private regdom for self-managed devices
      cfg80211: avoid intersection when applying self-managed reg
      nl80211: increase the max number of rules in regdomain
      mac80211: skip disabled channels in VHT check
      mac80211: add TDLS supported channels correctly
      cfg80211: introduce sync regdom set API for self-managed
      cfg80211: avoid reg-hints in self-managed only systems

Chaya Rachel Ivgi (1):
      mac80211: Fix ignored HT override configurations

Eliad Peller (6):
      mac80211: update sta bw on ht chanwidth action frame
      mac80211: avoid reconfig if no interfaces are up
      mac80211: fix dot11MulticastTransmittedFrameCount tested address
      mac80211: remove local->radar_detect_enabled
      mac80211: consider only relevant vifs for radar_required calculation
      mac80211: don't defer scans in case of radar detection

Emmanuel Grumbach (1):
      mac80211: let flush() drop packets when possible

Felix Fietkau (1):
      mac80211: minstrel: reduce size of struct minstrel_rate_stats

Gautam Kumar Shukla (1):
      cfg80211: add extensible feature flag attribute

Ido Yariv (1):
      mac80211: Re-fix accounting of the tailroom-needed counter

Janusz Dziedzic (1):
      mac80211: notify NSS changed when IBSS and HT

Johannes Berg (22):
      cfg80211: use __force __rcu to suppress sparse warning
      mac80211: ask driver to look at power level when starting AP
      mac80211: move U-APSD enablement to vif flags
      mac80211_hwsim: fix check for custom world regdom array size
      Revert "mac80211: Fix accounting of the tailroom-needed counter"
      nl80211: document NL80211_BSS_STATUS_AUTHENTICATED isn't used
      nl80211: define multicast group names in header
      Merge branch 'mac80211' into mac80211-next
      cfg80211: remove "channel" from survey names
      cfg80211: allow survey data to return global data
      cfg80211: add scan time to survey data
      cfg80211: allow including station info in delete event
      mac80211: send statistics with delete station event
      mac80211: allow drivers to provide most station statistics
      cfg80211: remove enum station_info_flags
      cfg80211: add nl80211 beacon-only statistics
      nl80211: clarify packet statistics descriptions
      nl80211: support per-TID station statistics
      mac80211: provide per-TID RX/TX MSDU counters
      mac80211_hwsim: fix PS debugfs file locking
      mac80211: fix handling TIM IE when stations disconnect
      cfg80211: docs: remove station_info_flags

Jonathan Doron (1):
      cfg80211: allow wiphy specific regdomain management

Jukka Rissanen (2):
      nl80211: Convert sched_scan_req pointer to RCU pointer
      nl80211: Stop scheduled scan if netlink client disappears

Luciano Coelho (3):
      mac80211: notify channel switch at the end of ieee80211_chswitch_post_beacon()
      mac80211: remove unused variable in ieee80211_parse_ch_switch_ie()
      nl80211: send netdetect configuration info in NL80211_CMD_GET_WOWLAN

Moshe Benji (1):
      mac80211: handle power constraint and country IEs in RRM

Nishikawa, Kenzoh (1):
      mac80211: keep sending peer candidate events while in listen state

Sujith Manoharan (2):
      mac80211: Move IEEE80211_TX_CTL_PS_RESPONSE
      mac80211: Fix accounting of multicast frames

Vadim Kochan (1):
      wireless: Support of IFLA_INFO_KIND rtnl attribute

 Documentation/DocBook/80211.tmpl                   |   1 -
 Documentation/kernel-parameters.txt                |  12 +
 Documentation/rfkill.txt                           |   3 +
 drivers/net/wireless/ath/ath10k/mac.c              |   3 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   8 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |  16 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  14 +-
 drivers/net/wireless/ath/ath6kl/main.c             |   1 -
 drivers/net/wireless/ath/ath9k/link.c              |  16 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   6 +-
 drivers/net/wireless/ath/carl9170/cmd.c            |  12 +-
 drivers/net/wireless/ath/carl9170/main.c           |   6 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  18 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   1 -
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |  11 +-
 drivers/net/wireless/cw1200/main.c                 |   1 -
 drivers/net/wireless/cw1200/sta.c                  |   4 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  13 +-
 drivers/net/wireless/libertas/cfg.c                |  12 +-
 drivers/net/wireless/mac80211_hwsim.c              |  30 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  17 +-
 drivers/net/wireless/mwifiex/uap_event.c           |   1 -
 drivers/net/wireless/mwl8k.c                       |  12 +-
 drivers/net/wireless/p54/eeprom.c                  |   6 +-
 drivers/net/wireless/p54/main.c                    |  10 +-
 drivers/net/wireless/p54/txrx.c                    |  12 +-
 drivers/net/wireless/rndis_wlan.c                  |   4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  12 +-
 drivers/net/wireless/ti/wl1251/main.c              |   5 +-
 drivers/net/wireless/ti/wlcore/main.c              |  22 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |   9 +-
 drivers/staging/wlan-ng/cfg80211.c                 |   4 +-
 include/net/cfg80211.h                             | 253 +++++----
 include/net/mac80211.h                             |  48 +-
 include/net/regulatory.h                           |  19 +
 include/uapi/linux/nl80211.h                       | 176 +++++-
 net/mac80211/cfg.c                                 |   7 +-
 net/mac80211/chan.c                                |  37 +-
 net/mac80211/debugfs.c                             |   2 -
 net/mac80211/driver-ops.h                          |  30 +-
 net/mac80211/ethtool.c                             |  26 +-
 net/mac80211/ibss.c                                |  11 +-
 net/mac80211/ieee80211_i.h                         |   8 +-
 net/mac80211/iface.c                               |   2 +-
 net/mac80211/key.c                                 |   9 +-
 net/mac80211/main.c                                |   4 -
 net/mac80211/mesh_plink.c                          |   7 +
 net/mac80211/mlme.c                                |  81 ++-
 net/mac80211/offchannel.c                          |   4 +-
 net/mac80211/pm.c                                  |   2 +-
 net/mac80211/rc80211_minstrel.c                    |   6 +-
 net/mac80211/rc80211_minstrel.h                    |  15 +-
 net/mac80211/rx.c                                  |  20 +-
 net/mac80211/scan.c                                |   8 +-
 net/mac80211/spectmgmt.c                           |   4 -
 net/mac80211/sta_info.c                            | 175 ++++--
 net/mac80211/sta_info.h                            |  12 +
 net/mac80211/status.c                              |  26 +-
 net/mac80211/tdls.c                                |  32 +-
 net/mac80211/trace.h                               |  33 +-
 net/mac80211/tx.c                                  |   5 +-
 net/mac80211/util.c                                |  29 +-
 net/mac80211/vht.c                                 |  73 +--
 net/wireless/core.c                                |  40 +-
 net/wireless/core.h                                |  11 +-
 net/wireless/nl80211.c                             | 627 ++++++++++++++-------
 net/wireless/nl80211.h                             |  16 +-
 net/wireless/reg.c                                 | 160 +++++-
 net/wireless/reg.h                                 |   1 +
 net/wireless/scan.c                                |  13 +-
 net/wireless/trace.h                               |  31 +-
 net/wireless/wext-compat.c                         |  10 +-
 72 files changed, 1614 insertions(+), 761 deletions(-)
