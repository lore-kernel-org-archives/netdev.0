From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2017-10-11
Date: Wed, 11 Oct 2017 14:36:12 +0200
Message-ID: <20171011123613.28890-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here's a -next pull request. The only bigger thing here is the
addition of the regulatory database as firmware, which will
allow us to - over time - get rid of CRDA, as well as having
the option of adding more fields to the database where needed,
this would've been extremely complex with CRDA because it had
not been built with extensibility in mind.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit cc71b7b071192ac1c288e272fdc3f3877eb96663:

  net/ipv6: remove unused err variable on icmpv6_push_pending_frames (2017-10-05 21:56:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-10-11

for you to fetch changes up to 90a53e4432b12288316efaa5f308adafb8d304b0:

  cfg80211: implement regdb signature checking (2017-10-11 14:24:24 +0200)

----------------------------------------------------------------
Work continues in various areas:
 * port authorized event for 4-way-HS offload (Avi)
 * enable MFP optional for such devices (Emmanuel)
 * Kees's timer setup patch for mac80211 mesh
   (the part that isn't trivially scripted)
 * improve VLAN vs. TXQ handling (myself)
 * load regulatory database as firmware file (myself)
 * with various other small improvements and cleanups

I merged net-next once in the meantime to allow Kees's
timer setup patch to go in.

----------------------------------------------------------------
Avraham Stern (2):
      ieee80211: Add WFA TPC report element OUI type
      cfg80211/nl80211: add a port authorized event

Emmanuel Grumbach (1):
      nl80211: add an option to allow MFP without requiring it

Gregory Greenman (1):
      mac80211: recalculate some sta parameters after insertion

Ilan peer (1):
      mac80211: Simplify locking in ieee80211_sta_tear_down_BA_sessions()

Johannes Berg (12):
      mac80211: avoid allocating TXQs that won't be used
      mac80211: simplify and clarify IE splitting
      mac80211: use offsetofend()
      cfg80211: remove unused function ieee80211_data_from_8023()
      Merge remote-tracking branch 'net-next/master' into mac80211-next
      MAINTAINERS: update Johannes Berg's entries
      fq: support filtering a given tin
      mac80211: only remove AP VLAN frames from TXQ
      cfg80211: support loading regulatory database as firmware file
      cfg80211: support reloading regulatory database
      cfg80211: reg: remove support for built-in regdb
      cfg80211: implement regdb signature checking

Kees Cook (1):
      net/mac80211/mesh_plink: Convert timers to use timer_setup()

Liad Kaufman (1):
      mac80211: extend ieee80211_ie_split to support EXTENSION

Lubomir Rintel (1):
      mac80211_hwsim: use dyndbg for debug messages

Luca Coelho (1):
      mac80211: add documentation to ieee80211_rx_ba_offl()

Manikanta Pubbisetty (1):
      mac80211: fix bandwidth computation for TDLS peers

Richard Schütz (1):
      wireless: set correct mandatory rate flags

Roee Zamir (2):
      nl80211: add OCE scan and capability flags
      mac80211: oce: enable receiving of bcast probe resp

Stanislaw Gruszka (1):
      mac80211: fix STA_SLOW_THRESHOLD htmldocs failure

Tova Mussai (1):
      nl80211: return error for invalid center_freq in 40 MHz

Xiang Gao (1):
      mac80211: aead api to reduce redundancy

 Documentation/driver-api/80211/cfg80211.rst |   3 -
 Documentation/networking/regulatory.txt     |  30 +-
 MAINTAINERS                                 |  13 +-
 drivers/net/wireless/mac80211_hwsim.c       | 192 ++++++------
 include/linux/ieee80211.h                   |   1 +
 include/net/cfg80211.h                      |  40 +--
 include/net/fq.h                            |   7 +
 include/net/fq_impl.h                       |  72 ++++-
 include/net/mac80211.h                      |   8 +-
 include/uapi/linux/nl80211.h                |  82 +++--
 net/mac80211/Makefile                       |   3 +-
 net/mac80211/{aes_ccm.c => aead_api.c}      |  40 +--
 net/mac80211/aead_api.h                     |  27 ++
 net/mac80211/aes_ccm.h                      |  42 ++-
 net/mac80211/aes_gcm.c                      | 109 -------
 net/mac80211/aes_gcm.h                      |  38 ++-
 net/mac80211/agg-rx.c                       |   4 +-
 net/mac80211/ht.c                           |  12 +-
 net/mac80211/ieee80211_i.h                  |   2 +
 net/mac80211/iface.c                        |  29 +-
 net/mac80211/mesh.c                         |   3 +-
 net/mac80211/mesh.h                         |   1 +
 net/mac80211/mesh_hwmp.c                    |   8 +-
 net/mac80211/mesh_plink.c                   |  13 +-
 net/mac80211/mlme.c                         |  19 +-
 net/mac80211/scan.c                         |  37 ++-
 net/mac80211/sta_info.c                     |  61 ++--
 net/mac80211/sta_info.h                     |   4 +-
 net/mac80211/tx.c                           |  34 +++
 net/mac80211/util.c                         |  25 +-
 net/mac80211/vht.c                          |  10 +
 net/mac80211/wpa.c                          |   4 +-
 net/wireless/.gitignore                     |   3 +-
 net/wireless/Kconfig                        |  58 ++--
 net/wireless/Makefile                       |  24 +-
 net/wireless/certs/sforshee.x509            | Bin 0 -> 680 bytes
 net/wireless/core.c                         |   2 +-
 net/wireless/core.h                         |   5 +
 net/wireless/db.txt                         |  17 --
 net/wireless/genregdb.awk                   | 158 ----------
 net/wireless/nl80211.c                      | 199 ++++++++----
 net/wireless/nl80211.h                      |   2 +
 net/wireless/reg.c                          | 452 +++++++++++++++++++++++++---
 net/wireless/reg.h                          |  14 +
 net/wireless/regdb.h                        |  23 --
 net/wireless/sme.c                          |  45 ++-
 net/wireless/util.c                         | 202 ++++---------
 47 files changed, 1278 insertions(+), 899 deletions(-)
 rename net/mac80211/{aes_ccm.c => aead_api.c} (67%)
 create mode 100644 net/mac80211/aead_api.h
 delete mode 100644 net/mac80211/aes_gcm.c
 create mode 100644 net/wireless/certs/sforshee.x509
 delete mode 100644 net/wireless/db.txt
 delete mode 100644 net/wireless/genregdb.awk
 delete mode 100644 net/wireless/regdb.h
