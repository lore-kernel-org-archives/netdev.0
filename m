From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [v2] pull-request: mac80211-next 2016-10-28
Date: Fri, 28 Oct 2016 13:02:50 +0200
Message-ID: <20161028110251.27840-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

First update for 4.10 - nothing major, new features as usual (FILS), and
sometimes we deprecate old stuff (WDS).

I don't have the fixes for the on-stack crypto/SG handling in this tree
(you already have them via mac80211.git), but we did make sure that the
fils_aead code doesn't re-introduce such an issue.

This one is with Arnd's fix included.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 6b25e21fa6f26d0f0d45f161d169029411c84286:

  Merge tag 'drm-for-v4.9' of git://people.freedesktop.org/~airlied/linux (2016-10-11 18:12:22 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-10-28

for you to fetch changes up to 514877182b537372352c14a0a50822572f66e831:

  mac80211: fils_aead: fix encrypt error handling (2016-10-28 12:59:12 +0200)

----------------------------------------------------------------
Among various cleanups and improvements, we have the following:
 * client FILS authentication support in mac80211 (Jouni)
 * AP/VLAN multicast improvements (Michael Braun)
 * config/advertising support for differing beacon intervals on
   multiple virtual interfaces (Purushottam Kushwaha, myself)
 * deprecate the old WDS mode for cfg80211-based drivers, the
   mode is hardly usable since it doesn't support any "modern"
   features like WPA encryption (2003), HT (2009) or VHT (2014),
   I'm not even sure WEP (introduced in 1997) could be done.

----------------------------------------------------------------
Andrei Otcheretianski (1):
      cfg80211: allow vendor commands to be sent to nan interface

Arend Van Spriel (1):
      cfg80211: add generic helper to check interface is running

Arnd Bergmann (1):
      mac80211: fils_aead: fix encrypt error handling

Emmanuel Grumbach (2):
      mac80211: allow the driver not to pass the tid to ieee80211_sta_uapsd_trigger
      mac80211: uapsd_queues is in QoS IE order

Ilan Peer (1):
      cfg80211: allow aborting in-progress connection atttempts

Johannes Berg (17):
      mac80211: remove unnecessary mesh check
      mac80211_hwsim: make multi-channel ops const
      mac80211: preserve more bits when building QoS header
      nl80211: correctly use nl80211_nan_srf_policy
      nl80211: ifdef WoWLAN related policies
      wireless: radiotap: fix timestamp sampling position values
      mac80211: fix tid_agg_rx NULL dereference
      mac80211: improve RX aggregation data in debugfs
      wireless: deprecate WDS and disable by default
      cfg80211: fix beacon interval in interface combination iteration
      cfg80211: mesh: track (and thus validate) beacon interval
      cfg80211: disallow beacon_int_min_gcd with IBSS
      cfg80211: validate beacon int as part of iface combinations
      mac80211: validate new interface's beacon intervals
      nl80211: move unsplit command advertising to a separate function
      nl80211: use nla_parse_nested() instead of nla_parse()
      cfg80211: handle fragmented IEs in splitting

Jouni Malinen (9):
      cfg80211: Rename SAE_DATA to more generic AUTH_DATA
      mac80211: Allow AUTH_DATA to be used for FILS
      cfg80211: Add feature flag for Fast Initial Link Setup (FILS) as STA
      cfg80211: Define IEEE P802.11ai (FILS) information elements
      cfg80211: Add Fast Initial Link Setup (FILS) auth algs
      cfg80211: Add KEK/nonces for FILS association frames
      mac80211: Add FILS auth alg mapping
      mac80211: FILS AEAD protection for station mode association frames
      mac80211: Claim Fast Initial Link Setup (FILS) STA support

Linus Lüssing (1):
      mac80211_hwsim: suggest nl80211 instead of wext driver in documentation

Michael Braun (5):
      mac80211: remove unnecessary num_mcast_sta check
      mac80211: filter multicast data packets on AP / AP_VLAN
      mac80211: avoid extra memcpy in A-MSDU head creation
      mac80211: fix A-MSDU outer SA/DA
      cfg80211: configure multicast to unicast for AP interfaces

Purushottam Kushwaha (2):
      cfg80211: pass struct to interface combination check/iter
      cfg80211: support virtual interfaces with different beacon intervals

Sara Sharon (1):
      mac80211: add a HW flag for supporting HW TX fragmentation

Wei Yongjun (1):
      cfg80211: fix possible memory leak in cfg80211_iter_combinations()

vamsi krishna (1):
      cfg80211: Add support to update connection parameters

 Documentation/networking/mac80211_hwsim/README     |   2 +-
 drivers/net/wireless/Kconfig                       |  13 +
 drivers/net/wireless/ath/ath10k/mac.c              |   1 +
 drivers/net/wireless/ath/ath9k/init.c              |   6 +
 drivers/net/wireless/broadcom/b43/main.c           |   2 +
 drivers/net/wireless/broadcom/b43legacy/main.c     |   2 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  22 +-
 drivers/net/wireless/mac80211_hwsim.c              |  79 ++--
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |   6 +-
 drivers/net/wireless/ti/wlcore/main.c              |   1 +
 include/linux/ieee80211.h                          |  26 ++
 include/net/cfg80211.h                             | 150 +++++--
 include/net/ieee80211_radiotap.h                   |   4 +-
 include/net/mac80211.h                             |  19 +-
 include/uapi/linux/nl80211.h                       |  69 +++-
 net/mac80211/Makefile                              |   1 +
 net/mac80211/aes_cmac.c                            |   8 +-
 net/mac80211/aes_cmac.h                            |   4 +
 net/mac80211/agg-rx.c                              |   8 +-
 net/mac80211/cfg.c                                 |  35 +-
 net/mac80211/debugfs.c                             |   1 +
 net/mac80211/debugfs_netdev.c                      |  11 +
 net/mac80211/debugfs_sta.c                         |   9 +-
 net/mac80211/fils_aead.c                           | 342 ++++++++++++++++
 net/mac80211/fils_aead.h                           |  19 +
 net/mac80211/ieee80211_i.h                         |  26 +-
 net/mac80211/iface.c                               |  16 +
 net/mac80211/main.c                                |   5 +
 net/mac80211/mlme.c                                |  60 ++-
 net/mac80211/rx.c                                  |  11 +-
 net/mac80211/sta_info.c                            |  23 +-
 net/mac80211/sta_info.h                            |   4 +-
 net/mac80211/tx.c                                  |  55 ++-
 net/mac80211/util.c                                |  61 +--
 net/mac80211/wme.c                                 |  23 +-
 net/mac80211/wpa.c                                 |   2 +-
 net/wireless/core.c                                |  33 +-
 net/wireless/core.h                                |   4 +-
 net/wireless/mesh.c                                |   2 +
 net/wireless/mlme.c                                |   6 +-
 net/wireless/nl80211.c                             | 445 +++++++++++++--------
 net/wireless/rdev-ops.h                            |  24 ++
 net/wireless/sme.c                                 |   2 +-
 net/wireless/trace.h                               |  37 ++
 net/wireless/util.c                                | 125 ++++--
 45 files changed, 1383 insertions(+), 421 deletions(-)
 create mode 100644 net/mac80211/fils_aead.c
 create mode 100644 net/mac80211/fils_aead.h
