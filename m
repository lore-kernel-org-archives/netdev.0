From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-10-18
Date: Tue, 18 Oct 2016 09:00:57 +0200
Message-ID: <1476774058-9279-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

As I mention in the tag message, the most urgent fix here is for
the VMAP_STACK vs. software crypto usage. I ended up applying Ard's
fix that dynamically allocates everything in one go, perhaps we'll
find a better solution in the future, but in the meantime this will
get things working again (rather than crashing or getting BUG_ON),
and normally it's a rarely used code path since hardware crypto is
used for almost all devices.

Please pull, or let me know if there's any problem.

Thanks,
johannes



The following changes since commit 6b25e21fa6f26d0f0d45f161d169029411c84286:

  Merge tag 'drm-for-v4.9' of git://people.freedesktop.org/~airlied/linux (2016-10-11 18:12:22 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-10-18

for you to fetch changes up to f4a067f9ffca603b45f7e82ddd2ba50e5904cea3:

  mac80211: move struct aead_req off the stack (2016-10-17 16:14:04 +0200)

----------------------------------------------------------------
This is relatively small, mostly to get the SG/crypto
from stack removal fix that crashes things when VMAP
stack is used in conjunction with software crypto.

Aside from that, we have:
 * a fix for AP_VLAN usage with the nl80211 frame command
 * two fixes (and two preparation patches) for A-MSDU, one
   to discard group-addressed (multicast) and unexpected
   4-address A-MSDUs, the other to validate A-MSDU inner
   MAC addresses properly to prevent controlled port bypass

----------------------------------------------------------------
Ard Biesheuvel (1):
      mac80211: move struct aead_req off the stack

Johannes Berg (4):
      mac80211: discard multicast and 4-addr A-MSDUs
      cfg80211: let ieee80211_amsdu_to_8023s() take only header-less SKB
      cfg80211: add ability to check DA/SA in A-MSDU decapsulation
      mac80211: validate DA/SA during A-MSDU decapsulation

Michael Braun (1):
      mac80211: fix CMD_FRAME for AP_VLAN

 .../net/wireless/marvell/mwifiex/11n_rxreorder.c   |  2 +-
 include/net/cfg80211.h                             | 32 ++++++++++----
 net/mac80211/aes_ccm.c                             | 46 ++++++++++++-------
 net/mac80211/aes_ccm.h                             |  8 ++--
 net/mac80211/aes_gcm.c                             | 43 +++++++++++-------
 net/mac80211/aes_gcm.h                             |  6 ++-
 net/mac80211/aes_gmac.c                            | 26 +++++------
 net/mac80211/aes_gmac.h                            |  4 ++
 net/mac80211/offchannel.c                          |  2 +-
 net/mac80211/rx.c                                  | 51 +++++++++++++++++-----
 net/mac80211/wpa.c                                 | 22 ++++------
 net/wireless/util.c                                | 34 +++++++--------
 12 files changed, 175 insertions(+), 101 deletions(-)
