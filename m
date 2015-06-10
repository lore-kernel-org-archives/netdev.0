From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2015-06-10
Date: Wed, 10 Jun 2015 15:09:12 +0200
Message-ID: <1433941752.3145.10.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

For -next, I have another set of changes, mostly small fixes for there
and a few cleanups. Kalle and I also decided to put in a big API change
that I'd been planning for a while and that required modifying all the
drivers, for that I pulled in your net-next tree before (re-)applying
that patch. Therefore, you shouldn't run into any conflicts now; without
that at least the new mediatek driver wouldn't have built.

Let me know if there are any issues.

Thanks,
johannes

The following changes since commit c3eee1fb1d308564ada5f7ea57bc51efc6130b37:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (2015-06-09 20:23:52 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-06-10

for you to fetch changes up to 5df03344c5639fdd848cb87553956df7276a8645:

  mac80211: convert HW flags to unsigned long bitmap (2015-06-10 13:48:42 +0200)

----------------------------------------------------------------
For this round we mostly have fixes:
 * mesh fixes from Alexis Green and Chun-Yeow Yeoh,
 * a documentation fix from Jakub Kicinski,
 * a missing channel release (from Michal Kazior),
 * a fix for a signal strength reporting bug (from Sara Sharon),
 * handle deauth while associating (myself),
 * don't report mangled TX SKB back to userspace for status (myself),
 * handle aggregation session timeouts properly in fast-xmit (myself)

However, there are also a few cleanups and one big change that
affects all drivers (and that required me to pull in your tree)
to change the mac80211 HW flags to use an unsigned long bitmap
so that we can extend them more easily - we're running out of
flags even with a cleanup to remove the two unused ones.

----------------------------------------------------------------
Alexis Green (3):
      mac80211: Fix incorrectly named last_hop_metric variable in mesh_rx_path_sel_frame
      mac80211: Always check rates and capabilities in mesh mode
      mac80211: Fix a case of incorrect metric used when forwarding a PREQ

Chun-Yeow Yeoh (1):
      mac80211: fix the beacon csa counter for mesh and ibss

Jakub Kicinski (1):
      mac80211: remove obsolete sentence from documentation

Johannes Berg (9):
      mac80211: act upon and report deauth while associating
      mac80211: move TX PN to public part of key struct
      mac80211: copy nl80211 mgmt TX SKB for status
      mac80211: stop using pointers as userspace cookies
      mac80211: remove short slot/short preamble incapable flags
      mac80211: rename single hw-scan flag to follow naming convention
      mac80211: handle aggregation session timeout on fast-xmit path
      Merge remote-tracking branch 'net-next/master' into mac80211-next
      mac80211: convert HW flags to unsigned long bitmap

Michal Kazior (1):
      mac80211: release channel on auth failure

Sara Sharon (1):
      mac80211: ignore invalid scan RSSI values

 drivers/net/wireless/adm8211.c                     |   8 +-
 drivers/net/wireless/at76c50x-usb.c                |   4 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |   6 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  34 ++--
 drivers/net/wireless/ath/ath5k/base.c              |  12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  20 +--
 drivers/net/wireless/ath/ath9k/init.c              |  24 +--
 drivers/net/wireless/ath/carl9170/fw.c             |   2 +-
 drivers/net/wireless/ath/carl9170/main.c           |  20 +--
 drivers/net/wireless/ath/wcn36xx/main.c            |  12 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |   4 +-
 drivers/net/wireless/b43/main.c                    |   4 +-
 drivers/net/wireless/b43legacy/main.c              |   5 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   7 +-
 drivers/net/wireless/cw1200/main.c                 |  16 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   6 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |  12 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  26 +--
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   4 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  32 ++--
 drivers/net/wireless/libertas_tf/main.c            |   2 +-
 drivers/net/wireless/mac80211_hwsim.c              |  26 +--
 drivers/net/wireless/mediatek/mt7601u/init.c       |  10 +-
 drivers/net/wireless/mwl8k.c                       |   9 +-
 drivers/net/wireless/p54/main.c                    |  12 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |   7 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   8 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   8 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   9 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  16 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   9 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   9 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   9 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   6 +-
 drivers/net/wireless/rtlwifi/base.c                |  22 ++-
 drivers/net/wireless/ti/wl1251/main.c              |   3 +-
 drivers/net/wireless/ti/wlcore/main.c              |  26 +--
 drivers/net/wireless/zd1211rw/zd_mac.c             |   8 +-
 drivers/staging/vt6655/device_main.c               |   8 +-
 drivers/staging/vt6656/main_usb.c                  |   8 +-
 include/net/mac80211.h                             | 106 ++++++------
 net/mac80211/agg-tx.c                              |   4 +-
 net/mac80211/cfg.c                                 | 178 ++++++++++++---------
 net/mac80211/debugfs.c                             | 103 ++++++------
 net/mac80211/debugfs_key.c                         |  17 +-
 net/mac80211/driver-ops.h                          |   2 +-
 net/mac80211/ibss.c                                |   1 +
 net/mac80211/iface.c                               |  10 +-
 net/mac80211/key.c                                 |  84 +++-------
 net/mac80211/key.h                                 |   4 -
 net/mac80211/main.c                                |  14 +-
 net/mac80211/mesh.c                                |   1 +
 net/mac80211/mesh_hwmp.c                           |  35 ++--
 net/mac80211/mesh_plink.c                          |   7 +-
 net/mac80211/mlme.c                                | 164 ++++++++++---------
 net/mac80211/offchannel.c                          |   2 +-
 net/mac80211/pm.c                                  |   4 +-
 net/mac80211/rate.c                                |   6 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   2 +-
 net/mac80211/rx.c                                  |  26 +--
 net/mac80211/scan.c                                |  18 ++-
 net/mac80211/sta_info.c                            |  14 +-
 net/mac80211/sta_info.h                            |   3 +
 net/mac80211/status.c                              | 135 +++++++++-------
 net/mac80211/tdls.c                                |  19 +--
 net/mac80211/tx.c                                  |  53 +++---
 net/mac80211/util.c                                |   6 +-
 net/mac80211/wpa.c                                 |  10 +-
 68 files changed, 758 insertions(+), 743 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
