From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-03-30
Date: Mon, 30 Mar 2015 17:23:16 +0200
Message-ID: <1427728996.26117.39.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47458 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbbC3PX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 11:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry for the late pull request, I had intended to send this earlier but
due to travel and various other things always got delayed.

The diffstat has all those drivers due to the name_assign_type change
that changes API in all of them, which of course couldn't go through
Kalle's tree.

Please pull, and let me know if there are any problems.

johannes

The following changes since commit b7853d73e39b099bbee149cac4c34dbf98f3fefa:

  bridge: add vlan info to bridge setlink and dellink notification messages (2015-02-22 23:00:45 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-03-30

for you to fetch changes up to 2c44be81f0fc147eed9dc63e2601318b2c007aeb:

  mac80211: set QoS capability before changing station state (2015-03-30 15:11:01 +0200)

----------------------------------------------------------------
Lots of updates for net-next; along with the usual flurry
of small fixes, cleanups and internal features we have:
 * VHT support for TDLS and IBSS (conditional on drivers though)
 * first TX performance improvements (the biggest will come later)
 * many suspend/resume (race) fixes
 * name_assign_type support from Tom Gundersen

----------------------------------------------------------------
Ahmad Kholaif (1):
      cfg80211: Allow NL80211_ATTR_IFINDEX to be added to vendor events

Alexander Bondar (1):
      mac80211: Update beacon's timing and DTIM count on every beacon

Arik Nemtsov (5):
      mac80211: TDLS: support VHT between peers
      mac80211: allow TDLS setup code to take wdev lock
      mac80211: allow iterating inactive interfaces
      cfg/mac80211: add regulatory classes IE during TDLS setup
      mac80211: send HT/VHT IEs in TDLS discovery response

Ben (1):
      cfg80211: Process all pending regulatory requests/hints

Bob Copeland (1):
      mac80211_hwsim: support any address in userspace

Cedric Izoard (1):
      mac80211: Get IV len from key conf and not cipher scheme

Dan Carpenter (1):
      mac80111: aes_ccm: cleanup ieee80211_aes_key_setup_encrypt()

David Spinadel (1):
      mac80211: stop scan before connection

Dedy Lansky (1):
      cfg80211: add bss_type and privacy arguments in cfg80211_get_bss()

Eliad Peller (1):
      cfg80211: add operating classes 128-130

Emmanuel Grumbach (5):
      mac80211: allow to get wireless_dev structure from ieee80211_vif
      mac80211: convert rssi_callback() to event_callback()
      mac80211: notify the driver about authentication status
      mac80211: notify the driver about association status
      mac80211: notify the driver about deauth

Felix Fietkau (1):
      mac80211: minstrel_ht: fix rounding issue in MCS duration calculation

Ilan peer (3):
      cfg80211: Simplify the handling of regulatory indoor setting
      cfg80211: Add API to change the indoor regulatory setting
      cfg80211: Schedule timeout for all CRDA calls

James Minor (1):
      cfg80211-wext: return -E2BIG when buffer can't hold full BSS entry

Janusz.Dziedzic@tieto.com (4):
      cfg80211: add VHT support for IBSS
      mac80211: IBSS: refactor ieee80211_rx_bss_info
      mac80211: IBSS fix scan request
      mac80211: add VHT support for IBSS

Johannes Berg (28):
      mac80211: don't look up stations for multicast addresses
      mac80211: iterate using station list in AP SMPS
      cfg80211-wext: export symbols only when needed
      mac80211: remove TX latency measurement code
      wext: add checked wrappers for adding events/points to streams
      nl80211: add notes about userspace API/ABI modifications
      mac80211: fix another suspend vs. association race
      mac80211: don't do driver suspend with auth/assoc in progress
      mac80211: start queues if driver rejected wowlan
      mac80211: check and dequeue skb in ieee80211_tx_prepare_skb()
      nl80211: prohibit mixing 'any' and regular wowlan triggers
      mac80211_hwsim: fix beacon timers
      mac80211: move netdev stats to common function
      mac80211: add comment for rx_path_lock
      mac80211: refactor drop connection/unlock in CSA processing
      mac80211: remove drop_unencrypted code
      mac80211: don't look up destination station twice
      mac80211: drop 4-addr VLAN frames earlier if not connected
      mac80211: mesh: avoid pointless station lookup
      mac80211: avoid duplicate TX path station lookup
      cfg80211: add vlan to station add/change tracing
      mac80211: agg-tx: avoid sending DelBA with sta->lock held
      mac80211: reject aggregation sessions with non-HT peers
      mac80111: aes_gcm: clean up ieee80211_aes_gcm_key_setup_encrypt()
      mac80211: send AP probe as unicast again
      mac80211: make sta.wme indicate whether QoS is used
      mac80211: factor out station lookup from ieee80211_build_hdr()
      mac80211: set QoS capability before changing station state

Jouni Malinen (2):
      mac80211_hwsim: Add minimal capability for vendor command/event testing
      mac80211: Fix misplaced return in AES-GMAC key setup

Luciano Coelho (5):
      mac80211: handle drv_add_interface failures properly during reconfig
      mac80211: remove useless double check for open_count in __ieee80211_suspend()
      mac80211: remove duplicate check for quiescing when queueing work
      nl80211: add net-detect delay to wowlan info
      nl80211: small clarification of the sched_scan delay attribute

Marek Puzyniak (1):
      mac80211: initialize rate control earlier for tdls station

Masashi Honma (1):
      nl/mac80211: allow zero plink timeout to disable STA expiration

Michael Braun (1):
      mac80211: fix typo in debug output

Nicholas Mc Guire (2):
      mesh_plink: use msecs_to_jiffies for proper time conversion
      mesh_plink: fixup type of timeout to match usage

SenthilKumar Jegadeesan (1):
      mac80211: provide station PMF configuration to driver

Tom Gundersen (1):
      cfg80211: pass name_assign_type to rdev_add_virtual_intf()

 drivers/net/wireless/ath/ath10k/mac.c              |   3 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  15 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |   1 +
 drivers/net/wireless/ath/ath6kl/core.c             |   4 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |   3 +
 drivers/net/wireless/brcm80211/brcmfmac/p2p.h      |   1 +
 drivers/net/wireless/cw1200/sta.c                  |   4 +-
 drivers/net/wireless/ipw2x00/Kconfig               |   2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  15 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |   2 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |   2 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   4 +-
 drivers/net/wireless/libertas/cfg.c                |   6 +-
 drivers/net/wireless/mac80211_hwsim.c              | 103 ++++++-
 drivers/net/wireless/mwifiex/cfg80211.c            |  13 +-
 drivers/net/wireless/mwifiex/main.c                |   6 +-
 drivers/net/wireless/mwifiex/main.h                |   1 +
 drivers/net/wireless/orinoco/Kconfig               |   2 +-
 drivers/net/wireless/ti/wl18xx/event.c             |   4 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |   6 +-
 include/net/cfg80211.h                             |  65 +++-
 include/net/iw_handler.h                           |  22 ++
 include/net/mac80211.h                             | 150 +++++++--
 include/uapi/linux/nl80211.h                       |  34 +-
 net/mac80211/aes_ccm.c                             |  12 +-
 net/mac80211/aes_gcm.c                             |  12 +-
 net/mac80211/aes_gmac.c                            |   4 +-
 net/mac80211/agg-rx.c                              |   8 +
 net/mac80211/agg-tx.c                              |  14 +-
 net/mac80211/cfg.c                                 |  97 +++---
 net/mac80211/debugfs.c                             | 170 ----------
 net/mac80211/debugfs_netdev.c                      |   2 -
 net/mac80211/debugfs_sta.c                         | 134 --------
 net/mac80211/driver-ops.h                          |  12 +-
 net/mac80211/ht.c                                  |   2 -
 net/mac80211/ibss.c                                | 341 +++++++++++++--------
 net/mac80211/ieee80211_i.h                         |  39 +--
 net/mac80211/iface.c                               |   4 +-
 net/mac80211/key.c                                 |   1 +
 net/mac80211/key.h                                 |   2 +
 net/mac80211/main.c                                |   4 +-
 net/mac80211/mesh.c                                |   3 +-
 net/mac80211/mesh_plink.c                          |  10 +-
 net/mac80211/mlme.c                                | 212 +++++++++----
 net/mac80211/pm.c                                  |  28 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   6 +-
 net/mac80211/rx.c                                  |  17 +-
 net/mac80211/scan.c                                |  25 +-
 net/mac80211/sta_info.c                            |  56 +---
 net/mac80211/sta_info.h                            |  22 --
 net/mac80211/status.c                              |  74 -----
 net/mac80211/tdls.c                                | 155 ++++++++--
 net/mac80211/trace.h                               |  14 +-
 net/mac80211/tx.c                                  | 266 +++++++++-------
 net/mac80211/util.c                                | 128 +++++++-
 net/mac80211/vht.c                                 |   4 -
 net/mac80211/wpa.c                                 |  13 +-
 net/wireless/Kconfig                               |   8 +
 net/wireless/ibss.c                                |   2 +-
 net/wireless/mlme.c                                |   6 +-
 net/wireless/nl80211.c                             |  84 ++++-
 net/wireless/rdev-ops.h                            |   5 +-
 net/wireless/reg.c                                 | 111 ++++---
 net/wireless/reg.h                                 |  15 +-
 net/wireless/scan.c                                | 302 ++++++++++++------
 net/wireless/sme.c                                 |  16 +-
 net/wireless/trace.h                               |  32 +-
 net/wireless/util.c                                | 130 ++++++++
 net/wireless/wext-compat.c                         |  18 +-
 net/wireless/wext-compat.h                         |   6 +
 72 files changed, 1909 insertions(+), 1190 deletions(-)
