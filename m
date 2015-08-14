From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2015-08-14
Date: Fri, 14 Aug 2015 17:54:36 +0200
Message-ID: <1439567676.2072.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

And, in addition to the fix before, I have a -next pull request. It's
actually quite big since I hadn't wanted to send one just before my
vacation.

Let me know if there are any issues.

johannes


The following changes since commit 923b352f19d9ea971ae2536eab55f5fc9e95fedf:

  cfg80211: use RTNL locked reg_can_beacon for IR-relaxation (2015-07-17 15:02:02 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-08-14

for you to fetch changes up to 8f9c98df949333f08b74e5df1caacf7e2c5e8552:

  mac80211: fix BIT position for TDLS WIDE extended cap (2015-08-14 17:49:53 +0200)

----------------------------------------------------------------
Another pull request for the next cycle, this time with quite
a bit of content:
 * mesh fixes/improvements from Alexis, Bob, Chun-Yeow and Jesse
 * TDLS higher bandwidth support (Arik)
 * OCB fixes from Bertold Van den Bergh
 * suspend/resume fixes from Eliad
 * dynamic SMPS support for minstrel-HT (Krishna Chaitanya)
 * VHT bitrate mask support (Lorenzo Bianconi)
 * better regulatory support for 5/10 MHz channels (Matthias May)
 * basic support for MU-MIMO to avoid the multi-vif issue (Sara Sharon)
along with a number of other cleanups.

----------------------------------------------------------------
Alexis Green (1):
      mac80211: mesh: add missing case to PERR processing

Arik Nemtsov (5):
      mac80211: define TDLS wider BW support bits
      mac80211: upgrade BW of TDLS peers when possible
      mac80211: TDLS: correctly configure SMPS state
      mac80211: TDLS: handle chan-switch in RTNL locked work
      mac80211: TDLS: deny ch-switch req on disallowed channels

Bertold Van den Bergh (4):
      nl80211: Allow setting multicast rate on OCB interfaces
      mac80211: Set txrc.bss to true for OCB interfaces
      mac80211: Only accept data frames in OCB mode
      mac80211: Make OCB mode set BSSID

Bob Copeland (4):
      mac80211: enable assoc check for mesh interfaces
      mac80211: reorder mesh_plink to remove forward decl
      mac80211: mesh: separate plid and aid concepts
      mac80211: select an AID when creating new mesh STAs

Chun-Yeow Yeoh (1):
      mac80211: mesh process the target only subfield for mesh hwmp

Dan Carpenter (1):
      mac80211: remove always true condition

Denys Vlasenko (2):
      mac80211: deinline drv_sta_state
      mac80211: deinline rate_control_rate_init, rate_control_rate_update

Eliad Peller (2):
      mac80211: clear local->in_reconfig on reconfig error
      mac80211: clear local->suspended before calling drv_resume()

Emmanuel Grumbach (1):
      mac80211: fix BIT position for TDLS WIDE extended cap

Geert Uytterhoeven (1):
      rfkill: Allow compile test of GPIO consumers if !GPIOLIB

Jesse Jones (2):
      mac80211: mesh: don't invalidate SN on discovery failure
      mac80211: mac80211: Check SN for deactivated mpaths

Johannes Berg (26):
      mac80211: remove exposing 'mfp' to drivers
      mac80211: rename 'sta_inf' variable to more common 'sta'
      mac80211: remove sta_info.gtk_idx
      mac80211: remove short frame test and counter
      mac80211: move ieee80211_get_bssid into RX file
      mac80211: fix comment referring to RX queue
      mac80211: don't store napi struct
      mac80211: remove zero-length A-MPDU subframe reporting
      mac80211: remove key TX/RX counter
      mac80211: support device/driver PN check for CCMP/GCMP
      mac80211: duplicate station's MAC address for hash table
      mac80211: remove IEEE80211_RX_FRAGMENTED
      mac80211: move mesh related station fields to own struct
      mac80211: move mesh STA parameters code to own function
      mac80211: allow passing NULL to ieee80211_vif_to_wdev()
      mac80211_hwsim: support wider TDLS bandwidth
      mac80211: add pointer for driver use to key
      mac80211: mesh: move fail_avg into mesh struct
      mac80211: shrink struct ieee80211_fragment_entry
      cfg80211: allow mgmt_frame_register callback to sleep
      mac80211: account TX MSDUs properly with segmentation offload
      Merge branch 'mac80211' into mac80211-next
      iwlwifi: mvm: don't set K1/K2 for AES-CMAC
      mac80211: remove ieee80211_aes_cmac_calculate_k1_k2()
      average: provide macro to create static EWMA
      mac80211: use DECLARE_EWMA

John Linville (1):
      wireless: remove superfluous if statement in regulatory code

Krishna Chaitanya (1):
      mac80211: minstrel_ht: handle peers in dynamic SMPS

Lorenzo Bianconi (4):
      mac80211: remove ieee80211_tx_info from rate_control_apply_mask signature
      mac80211: remove ieee80211_tx_rate dependency in rate mask code
      mac80211: define rate_control_apply_mask_ratetbl()
      mac80211: add rate mask logic for vht rates

Matthias May (1):
      cfg80211: regulatory: handle 5 and 10 MHz channels properly

Michal Kazior (1):
      cfg80211: propagate set_wiphy failure to userspace

Sara Sharon (1):
      mac80211: Add support for declaring MU-MIMO capability

Su Kang Yin (1):
      mac80211_hwsim: unregister genetlink family properly

Wojciech Dubowik (1):
      mac80211: avoid unnecessary beacon deref on CSA counter update

 drivers/net/wireless/iwlwifi/dvm/dev.h        |   2 +
 drivers/net/wireless/iwlwifi/dvm/main.c       |   3 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c         |   2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h |   4 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h        |   1 +
 drivers/net/wireless/iwlwifi/mvm/ops.c        |   3 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c         |   2 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c        |   2 -
 drivers/net/wireless/mac80211_hwsim.c         |   5 +-
 include/linux/average.h                       |  39 +++
 include/linux/ieee80211.h                     |   2 +-
 include/net/cfg80211.h                        |   3 +-
 include/net/mac80211.h                        |  69 +++---
 net/mac80211/Kconfig                          |   1 -
 net/mac80211/Makefile                         |   1 +
 net/mac80211/aes_cmac.c                       |  17 --
 net/mac80211/cfg.c                            | 161 ++++++++-----
 net/mac80211/chan.c                           |  31 ++-
 net/mac80211/debugfs.c                        |   2 +-
 net/mac80211/debugfs_key.c                    |   2 -
 net/mac80211/debugfs_netdev.c                 |  34 +++
 net/mac80211/driver-ops.c                     |  41 ++++
 net/mac80211/driver-ops.h                     |  29 +--
 net/mac80211/ieee80211_i.h                    |  42 ++--
 net/mac80211/iface.c                          |  16 +-
 net/mac80211/key.c                            |   1 -
 net/mac80211/key.h                            |   3 -
 net/mac80211/main.c                           |  17 +-
 net/mac80211/mesh.c                           |   2 +-
 net/mac80211/mesh_hwmp.c                      |  80 ++++---
 net/mac80211/mesh_plink.c                     | 326 ++++++++++++++------------
 net/mac80211/mesh_ps.c                        |  42 ++--
 net/mac80211/mesh_sync.c                      |  16 +-
 net/mac80211/mlme.c                           |  61 +++--
 net/mac80211/ocb.c                            |   2 +-
 net/mac80211/rate.c                           | 310 ++++++++++++++++++------
 net/mac80211/rate.h                           |  60 +----
 net/mac80211/rc80211_minstrel_ht.c            |   8 +-
 net/mac80211/rx.c                             | 101 +++++---
 net/mac80211/sta_info.c                       |  52 ++--
 net/mac80211/sta_info.h                       | 120 ++++++----
 net/mac80211/status.c                         |   5 +-
 net/mac80211/tdls.c                           | 242 ++++++++++++++++---
 net/mac80211/tx.c                             |  35 +--
 net/mac80211/util.c                           |  75 ++----
 net/mac80211/vht.c                            |  34 ++-
 net/mac80211/wpa.c                            |  83 ++++---
 net/rfkill/Kconfig                            |   3 +-
 net/wireless/core.c                           |   5 +
 net/wireless/core.h                           |   5 +
 net/wireless/mlme.c                           |  75 ++++--
 net/wireless/nl80211.c                        |   4 +-
 net/wireless/rdev-ops.h                       |   2 +
 net/wireless/reg.c                            |  73 ++++--
 54 files changed, 1510 insertions(+), 846 deletions(-)
 create mode 100644 net/mac80211/driver-ops.c
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
