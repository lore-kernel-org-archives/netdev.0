From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2017-02-09
Date: Thu,  9 Feb 2017 15:27:33 +0100
Message-ID: <20170209142734.21891-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:60250 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753080AbdBIO1n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 09:27:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here are some more (final) updates for -next. Nothing here is
really interesting, mostly cleanups and small fixes.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit d140199af510ad4749dc5e38b7922135258ba5fd:

  bpf, lpm: fix kfree of im_node in trie_update_elem (2017-01-23 21:17:35 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-02-09

for you to fetch changes up to f181d6a3bcc35633facf5f3925699021c13492c5:

  mac80211: fix CSA in IBSS mode (2017-02-09 15:18:24 +0100)

----------------------------------------------------------------
Some more updates:
 * use shash in mac80211 crypto code where applicable
 * some documentation fixes
 * pass RSSI levels up in change notifications
 * remove unused rfkill-regulator
 * various other cleanups

----------------------------------------------------------------
Amadeusz Sławiński (1):
      mac80211: use helper function to access ieee802_1d_to_ac[]

Andrzej Zaborowski (2):
      mac80211: Pass new RSSI level in CQM RSSI notification
      cfg80211: Pass new RSSI level in CQM RSSI notification

Ard Biesheuvel (2):
      mac80211: fils_aead: Use crypto api CMAC shash rather than bare cipher
      mac80211: aes-cmac: switch to shash CMAC driver

Arend Van Spriel (1):
      nl80211: fix validation of scheduled scan info for wowlan netdetect

Dan Carpenter (1):
      mac80211: check for allocation failure in debugfs code

Johannes Berg (7):
      cfg80211: fix a documentation warning
      mac80211: fix documentation warnings
      rfkill: remove rfkill-regulator
      wireless: radiotap: rewrite the radiotap header file
      wireless: define cipher/AKM suites using a macro
      mac80211: add back lost debugfs files
      nl80211: add HT/VHT capabilities to AP parameters

Koen Vandeputte (1):
      mac80211: fix CSA in IBSS mode

Luca Coelho (2):
      cfg80211: make rdev assignment clearer in nl80211_testmode_dump()
      cfg80211: fix NAN bands definition

Pichugin Dmitry (1):
      cfg80211 debugfs: Cleanup some checkpatch issues

 drivers/net/wireless/intel/iwlwifi/mvm/rx.c      |   2 +
 drivers/net/wireless/marvell/mwifiex/sta_event.c |   4 +-
 drivers/net/wireless/rndis_wlan.c                |   2 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c      |   2 +-
 drivers/net/wireless/st/cw1200/sta.c             |   2 +-
 drivers/net/wireless/ti/wl1251/event.c           |   4 +-
 drivers/net/wireless/ti/wlcore/event.c           |   3 +-
 include/linux/ieee80211.h                        |  49 +--
 include/linux/rfkill-regulator.h                 |  48 ---
 include/net/cfg80211.h                           |  92 +++--
 include/net/ieee80211_radiotap.h                 | 455 ++++++++---------------
 include/net/mac80211.h                           |  76 ++--
 include/uapi/linux/nl80211.h                     |  60 ++-
 net/mac80211/Kconfig                             |   1 +
 net/mac80211/aes_cmac.c                          | 126 ++-----
 net/mac80211/aes_cmac.h                          |  15 +-
 net/mac80211/cfg.c                               |   4 +-
 net/mac80211/debugfs.c                           |  12 +-
 net/mac80211/debugfs_sta.c                       |   1 +
 net/mac80211/fils_aead.c                         |  74 ++--
 net/mac80211/ibss.c                              |   4 +-
 net/mac80211/key.h                               |   2 +-
 net/mac80211/mlme.c                              |   9 +-
 net/mac80211/rx.c                                |   2 +-
 net/mac80211/status.c                            |   2 +-
 net/mac80211/trace.h                             |  27 +-
 net/mac80211/tx.c                                |   4 +-
 net/rfkill/Kconfig                               |  11 -
 net/rfkill/Makefile                              |   1 -
 net/rfkill/rfkill-regulator.c                    | 154 --------
 net/wireless/core.c                              |   3 +-
 net/wireless/debugfs.c                           |  10 +-
 net/wireless/nl80211.c                           | 114 ++++--
 net/wireless/trace.h                             |  27 +-
 34 files changed, 559 insertions(+), 843 deletions(-)
 delete mode 100644 include/linux/rfkill-regulator.h
 delete mode 100644 net/rfkill/rfkill-regulator.c
