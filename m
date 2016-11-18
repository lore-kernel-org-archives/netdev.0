From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-11-18
Date: Fri, 18 Nov 2016 08:52:00 +0100
Message-ID: <20161118075201.30081-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Due to travel/vacation, this is a bit late, but there aren't
that many fixes either. Most interesting/important are the
fixes from Felix and perhaps the scan entry limit.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 269ebce4531b8edc4224259a02143181a1c1d77c:

  xen-netfront: cast grant table reference first to type int (2016-11-02 15:33:36 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-11-18

for you to fetch changes up to 9853a55ef1bb66d7411136046060bbfb69c714fa:

  cfg80211: limit scan results cache size (2016-11-18 08:44:44 +0100)

----------------------------------------------------------------
A few more bugfixes:
 * limit # of scan results stored in memory - this is a long-standing bug
   Jouni and I only noticed while discussing other things in Santa Fe
 * revert AP_LINK_PS patch that was causing issues (Felix)
 * various A-MSDU/A-MPDU fixes for TXQ code (Felix)
 * interoperability workaround for peers with broken VHT capabilities
   (Filip Matusiak)
 * add bitrate definition for a VHT MCS that's supposed to be invalid
   but gets used by some hardware anyway (Thomas Pedersen)
 * beacon timer fix in hwsim (Benjamin Beichler)

----------------------------------------------------------------
Benjamin Beichler (1):
      mac80211_hwsim: fix beacon delta calculation

Felix Fietkau (4):
      Revert "mac80211: allow using AP_LINK_PS with mac80211-generated TIM IE"
      mac80211: update A-MPDU flag on tx dequeue
      mac80211: remove bogus skb vif assignment
      mac80211: fix A-MSDU aggregation with fast-xmit + txq

Filip Matusiak (1):
      mac80211: Ignore VHT IE from peer with wrong rx_mcs_map

Johannes Berg (1):
      cfg80211: limit scan results cache size

Pedersen, Thomas (1):
      cfg80211: add bitrate for 20MHz MCS 9

 drivers/net/wireless/mac80211_hwsim.c |  2 +-
 net/mac80211/sta_info.c               |  2 +-
 net/mac80211/tx.c                     | 14 +++++--
 net/mac80211/vht.c                    | 16 ++++++++
 net/wireless/core.h                   |  1 +
 net/wireless/scan.c                   | 69 +++++++++++++++++++++++++++++++++++
 net/wireless/util.c                   |  3 +-
 7 files changed, 100 insertions(+), 7 deletions(-)
