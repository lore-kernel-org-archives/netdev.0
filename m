From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2016-04-06
Date: Wed,  6 Apr 2016 15:25:58 +0200
Message-ID: <1459949159-22399-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

=46or the 4.6 cycle, there's of course much more. The few things that
stand out are in the tag message below.

There's a pending patchset to add NAN (Neighbor Awareness Networking,
a WFA protocol) API support, but the API isn't ready yet. I might
have that later in time for 4.6.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 05cf8077e54b20dddb756eaa26f3aeb5c38d=
d3cf:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
4-01 20:03:33 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git=
 tags/mac80211-next-for-davem-2016-04-06

for you to fetch changes up to 4ce2bd9c4c1dfb416206ff1ad5283f6d24af4031=
:

  cfg80211: Allow reassociation to be requested with internal SME (2016=
-04-06 15:09:28 +0200)

----------------------------------------------------------------
=46or the 4.6 cycle, we have a number of changes:
 * Bob's mesh mode rhashtable conversion, this includes
   the rhashtable API change for allocation flags
 * BSSID scan, connect() command reassoc support (Jouni)
 * fast (optimised data only) and support for RSS in mac80211 (myself)
 * various smaller changes

----------------------------------------------------------------
Akira Moroo (1):
      cfg80211: fix kernel-doc struct name

Arend van Spriel (1):
      nl80211: add feature for BSS selection support

Avraham Stern (1):
      ieee80211: support parsing Fine Timing Measurement action frame

Ayala Beker (2):
      cfg80211: allow userspace to specify client P2P PS support
      mac80211: track and tell driver about GO client P2P PS abilities

Bob Copeland (14):
      mac80211: mesh: move path tables into if_mesh
      mac80211: mesh: don't hash sdata in mpath tables
      mac80211: mesh: factor out common mesh path allocation code
      mac80211: mesh: embed known gates list in struct mesh_path
      rhashtable: accept GFP flags in rhashtable_walk_init
      mac80211: mesh: convert path table to rhashtable
      mac80211: mesh: fix crash in mesh_path_timer
      mac80211: mesh: handle failed alloc for rmc cache
      mac80211: mesh: use hlist for rmc cache
      mac80211: mesh: embed gates hlist head directly
      mac80211: mesh: reorder structure members
      mac80211: mesh: fix mesh path kerneldoc
      mac80211: mesh: fix cleanup for mesh pathtable
      mac80211: mesh: flush paths outside of plink lock

Emmanuel Grumbach (1):
      mac80211: Set global RRM capability

=46elix Fietkau (4):
      mac80211: do not pass injected frames without a valid rate to the=
 driver
      mac80211: minstrel_ht: improve sample rate skip logic
      mac80211: add A-MSDU tx support
      mac80211: minstrel_ht: set A-MSDU tx limits based on selected max=
_prob_rate

Johannes Berg (17):
      wext: unregister_pernet_subsys() on notifier registration failure
      mac80211: allow drivers to report CLOCK_BOOTTIME for scan results
      mac80211: remove sta_info debugfs sub-struct
      mac80211: don't start dynamic PS timer if not needed
      mac80211: clean up station flags debugfs
      mac80211: fix cipher scheme function name
      mac80211: avoid useless memory write on each frame RX
      mac80211: allow passing transmitter station on RX
      mac80211: count MSDUs in A-MSDU properly
      mac80211: move semicolon out of CALL_RXH macro
      mac80211: move averaged values out of rx_stats
      mac80211: remove rx_stats.last_rx update after sta alloc
      mac80211: add separate last_ack variable
      mac80211: fix last RX rate data consistency
      mac80211: fix RX u64 stats consistency on 32-bit platforms
      mac80211: add fast-rx path
      mac80211: enable collecting station statistics per-CPU

Jouni Malinen (5):
      cfg80211: Allow a scan request for a specific BSSID
      mac80211: Support a scan request for a specific BSSID
      mac80211_hwsim: Support a hw scan request for a specific BSSID
      cfg80211: Add option to specify previous BSSID for Connect comman=
d
      cfg80211: Allow reassociation to be requested with internal SME

Jo=C3=A3o Paulo Rechi Vita (1):
      rfkill: Use switch to demux userspace operations

Lorenzo Bianconi (1):
      mac80211: parse VHT info in injected frames

Mohammed Shafi Shajakhan (1):
      mac80211: Remove unused variable in per STA debugfs struct

Sara Sharon (4):
      mac80211: allow not sending MIC up from driver for HW crypto
      mac80211: synchronize driver rx queues before removing a station
      mac80211: add NETIF_F_RXCSUM to features white list
      mac80211: enable starting BA session with custom timeout

Sven Eckelmann (2):
      mac80211: document only injected *_RADIOTAP_* flags
      mac80211: fix parsing of 40Mhz in injected radiotap header

 Documentation/networking/mac80211-injection.txt   |  17 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c          |   2 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c           |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c       |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c       |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c     |   2 +-
 drivers/net/wireless/mac80211_hwsim.c             |   5 +
 fs/gfs2/glock.c                                   |   4 +-
 include/linux/ieee80211.h                         |  24 +
 include/linux/rhashtable.h                        |   3 +-
 include/net/cfg80211.h                            |  42 +-
 include/net/mac80211.h                            |  51 +-
 include/uapi/linux/nl80211.h                      |  75 +-
 lib/rhashtable.c                                  |   6 +-
 lib/test_rhashtable.c                             |   2 +-
 net/ipv6/ila/ila_xlat.c                           |   3 +-
 net/mac80211/agg-tx.c                             |   5 +
 net/mac80211/cfg.c                                |  18 +-
 net/mac80211/debugfs.c                            |   3 +
 net/mac80211/debugfs_sta.c                        | 134 +--
 net/mac80211/driver-ops.h                         |  15 +
 net/mac80211/ibss.c                               |  17 +-
 net/mac80211/ieee80211_i.h                        |  11 +
 net/mac80211/iface.c                              |   2 +-
 net/mac80211/key.c                                |   1 +
 net/mac80211/main.c                               |   4 +-
 net/mac80211/mesh.c                               |  38 +-
 net/mac80211/mesh.h                               |  71 +-
 net/mac80211/mesh_hwmp.c                          |   4 +
 net/mac80211/mesh_pathtbl.c                       | 965 ++++++++------=
--------
 net/mac80211/mesh_plink.c                         |  13 +-
 net/mac80211/mlme.c                               |  16 +-
 net/mac80211/ocb.c                                |   2 -
 net/mac80211/rate.h                               |   4 +-
 net/mac80211/rc80211_minstrel_ht.c                |  77 +-
 net/mac80211/rx.c                                 | 479 +++++++++--
 net/mac80211/scan.c                               |   8 +-
 net/mac80211/sta_info.c                           | 289 +++++--
 net/mac80211/sta_info.h                           | 130 ++-
 net/mac80211/status.c                             |   4 +-
 net/mac80211/trace.h                              |  12 +
 net/mac80211/tx.c                                 | 197 ++++-
 net/mac80211/util.c                               |   5 +-
 net/mac80211/wpa.c                                |  26 +-
 net/netfilter/nft_hash.c                          |   4 +-
 net/netlink/af_netlink.c                          |   3 +-
 net/rfkill/core.c                                 |  36 +-
 net/sctp/proc.c                                   |   3 +-
 net/wireless/core.c                               |   7 +
 net/wireless/nl80211.c                            | 158 +++-
 net/wireless/scan.c                               |   2 +
 net/wireless/sme.c                                |  16 +-
 net/wireless/trace.h                              |   6 +-
 net/wireless/wext-core.c                          |   5 +-
 55 files changed, 2029 insertions(+), 1005 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
