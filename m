From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2017-01-13
Date: Fri, 13 Jan 2017 11:29:32 +0100
Message-ID: <20170113102933.8246-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is my first pull request for net-next, and it seems a bit
bigger than the past few releases. Detailed information below,
as usual.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 8fa3b6f9392bf6d90cb7b908e07bd90166639f0a:

  Merge tag 'cris-for-4.10' of git://git.kernel.org/pub/scm/linux/kernel/git/jesper/cris (2016-12-12 09:06:38 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-01-13

for you to fetch changes up to c88215d7050f065afaed33e9599c2ef4e5e6ee22:

  cfg80211: Fix documentation for connect result (2017-01-13 09:47:08 +0100)

----------------------------------------------------------------
For 4.11, we seem to have more than in the past few releases:
 * socket owner support for connections, so when the wifi
   manager (e.g. wpa_supplicant) is killed, connections are
   torn down - wpa_supplicant is critical to managing certain
   operations, and can opt in to this where applicable
 * minstrel & minstrel_ht updates to be more efficient (time and space)
 * set wifi_acked/wifi_acked_valid for skb->destructor use in the
   kernel, which was already available to userspace
 * don't indicate new mesh peers that might be used if there's no
   room to add them
 * multicast-to-unicast support in mac80211, for better medium usage
   (since unicast frames can use *much* higher rates, by ~3 orders of
   magnitude)
 * add API to read channel (frequency) limitations from DT
 * add infrastructure to allow randomizing public action frames for
   MAC address privacy (still requires driver support)
 * many cleanups and small improvements/fixes across the board

----------------------------------------------------------------
Andrzej Zaborowski (1):
      cfg80211: NL80211_ATTR_SOCKET_OWNER support for CMD_CONNECT

Arend Van Spriel (5):
      cfg80211: get rid of name indirection trick for ieee80211_get_channel()
      nl80211: check NL80211_ATTR_SCHED_SCAN_INTERVAL only once
      nl80211: rework {sched_,}scan event related functions
      nl80211: better describe field in struct nl80211_bss_select_rssi_adjust
      cfg80211: only pass sband to set_mandatory_flags_band()

Arnd Bergmann (2):
      rfkill: hide unused goto label
      wext: handle NULL extra data in iwe_stream_add_point better

Ben Greear (1):
      mac80211: Show pending txqlen in debugfs.

David Spinadel (1):
      mac80211: Add RX flag to indicate ICV stripped

Felix Fietkau (9):
      mac80211: minstrel_ht: move supported bitrate mask out of group data
      mac80211: minstrel_ht: move short preamble check out of get_rate
      mac80211: minstrel_ht: make att_hist and succ_hist u32 instead of u64
      mac80211: check for MCS in ieee80211_duration before fetching chanctx
      mac80211: minstrel: remove cur_prob from debugfs
      mac80211: minstrel: reduce MINSTREL_SCALE
      mac80211: minstrel: store probability variance instead of standard deviation
      mac80211: minstrel: make prob_ewma u16 instead of u32
      mac80211: minstrel_ht: remove obsolete #if for >= 3 streams

Ilan peer (1):
      mac80211: Fix addition of mesh configuration element

Johannes Berg (7):
      rfkill: simplify rfkill_set_hw_state() slightly
      Revert "rfkill: Add rfkill-any LED trigger"
      cfg80211: sysfs: use wiphy_name()
      wireless: move IEEE80211_NUM_ACS to ieee80211.h
      cfg80211: size various nl80211 messages correctly
      mac80211: set wifi_acked[_valid] bits for transmitted SKBs
      wext: uninline stream addition functions

Jorge Ramirez-Ortiz (1):
      cfg80211: wext does not need to set monitor channel in managed mode

Jouni Malinen (1):
      cfg80211: Fix documentation for connect result

Kirtika Ruchandani (7):
      mac80211: Remove unused 'struct ieee80211_rx_status' ptr
      mac80211: Remove unused 'rates_idx' variable
      mac80211: Remove unused 'struct rate_control_ref' variable
      mac80211: Remove unused 'i' variable
      mac80211: Remove unused 'len' variable
      mac80211: Remove unused 'sband' and 'local' variables
      mac80211: Remove unused 'beaconint_us' variable

Koen Vandeputte (1):
      mac80211: only alloc mem if a station doesn't exist yet

Masashi Honma (3):
      mac80211: Suppress NEW_PEER_CANDIDATE event if no room
      mac80211: Remove invalid flag operations in mesh TSF synchronization
      mac80211: Use appropriate name for functions and messages

Michael Braun (2):
      nl80211: multicast_to_unicast can be changed while IFF_UP
      mac80211: multicast to unicast conversion

Michał Kępień (3):
      rfkill: Cleanup error handling in rfkill_init()
      rfkill: Add rfkill-any LED trigger
      rfkill: Add rfkill-any LED trigger

Purushottam Kushwaha (1):
      cfg80211: Specify the reason for connect timeout

Rafał Miłecki (5):
      cfg80211: update wireless-regdb repo url in Documentation
      cfg80211: fix example REG_RULE usage in Documentation
      dt-bindings: document common IEEE 802.11 frequency limit property
      cfg80211: move function checking range fit to util.c
      cfg80211: support ieee80211-freq-limit DT property

Thomas Huehn (1):
      mac80211: minstrel: avoid port control frames for sampling

vamsi krishna (2):
      cfg80211: Add support for randomizing TA of Public Action frames
      cfg80211: Add support to sched scan to report better BSSs

 Documentation/80211/cfg80211.rst                   |   3 +
 .../devicetree/bindings/net/wireless/ieee80211.txt |  24 ++++
 Documentation/networking/regulatory.txt            |   8 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   3 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   2 +-
 include/linux/ieee80211.h                          |   2 +
 include/net/cfg80211.h                             | 135 ++++++++++++++------
 include/net/iw_handler.h                           |  66 ++--------
 include/net/mac80211.h                             |   6 +-
 include/uapi/linux/nl80211.h                       |  64 +++++++++-
 net/mac80211/cfg.c                                 |  12 ++
 net/mac80211/chan.c                                |   4 +-
 net/mac80211/debugfs.c                             |  27 ++++
 net/mac80211/debugfs_netdev.c                      |   3 +
 net/mac80211/ieee80211_i.h                         |   6 +-
 net/mac80211/mesh.c                                |   7 +-
 net/mac80211/mesh.h                                |   2 +-
 net/mac80211/mesh_plink.c                          |  14 ++-
 net/mac80211/mesh_sync.c                           |  27 ++--
 net/mac80211/mlme.c                                |   4 -
 net/mac80211/rc80211_minstrel.c                    |  21 ++--
 net/mac80211/rc80211_minstrel.h                    |  33 ++---
 net/mac80211/rc80211_minstrel_debugfs.c            |  24 ++--
 net/mac80211/rc80211_minstrel_ht.c                 |  68 +++-------
 net/mac80211/rc80211_minstrel_ht.h                 |   6 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |  32 ++---
 net/mac80211/rx.c                                  |   4 -
 net/mac80211/scan.c                                |   8 +-
 net/mac80211/sta_info.c                            |  18 ++-
 net/mac80211/status.c                              |   8 +-
 net/mac80211/tx.c                                  | 132 +++++++++++++++++++-
 net/mac80211/vht.c                                 |   4 -
 net/mac80211/wep.c                                 |   3 +-
 net/mac80211/wpa.c                                 |   3 +-
 net/rfkill/core.c                                  | 100 ++++++++++++---
 net/wireless/Makefile                              |   1 +
 net/wireless/core.c                                |   3 +
 net/wireless/core.h                                |   8 +-
 net/wireless/mlme.c                                |  29 ++++-
 net/wireless/nl80211.c                             | 137 +++++++++++++-------
 net/wireless/nl80211.h                             |  10 +-
 net/wireless/of.c                                  | 138 +++++++++++++++++++++
 net/wireless/reg.c                                 |  27 ++--
 net/wireless/scan.c                                |   9 +-
 net/wireless/sme.c                                 |  72 +++++++++--
 net/wireless/sysfs.c                               |   6 +-
 net/wireless/util.c                                |  30 +++--
 net/wireless/wext-core.c                           |  67 ++++++++++
 net/wireless/wext-sme.c                            |  23 ----
 49 files changed, 1016 insertions(+), 427 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ieee80211.txt
 create mode 100644 net/wireless/of.c
