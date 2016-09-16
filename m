From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2016-09-16
Date: Fri, 16 Sep 2016 14:56:45 +0200
Message-ID: <1474030606-16664-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59449 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752881AbcIPM4y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 08:56:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

And here's another set for net-next, it's been a month or so and we have a
reasonably large number of patches (for a change, mostly because I cleaned
up some WEP crypto thing and a few static checkers.)

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 02154927c115c7599677df57203988e05b576346:

  net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device (2016-09-11 19:37:02 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-09-16

for you to fetch changes up to fbd05e4a6e82fd573d3aa79e284e424b8d78c149:

  cfg80211: add helper to find an IE that matches a byte-array (2016-09-16 14:49:52 +0200)

----------------------------------------------------------------
This time we have various things - all across the board:
 * MU-MIMO sniffer support in mac80211
 * a create_singlethread_workqueue() cleanup
 * interface dump filtering that was documented but not implemented
 * support for the new radiotap timestamp field
 * send delBA in two unexpected conditions (as required by the spec)
 * connect keys cleanups - allow only WEP with index 0-3
 * per-station aggregation limit to work around broken APs
 * debugfs improvement for the integrated codel algorithm
and various other small improvements and cleanups.

----------------------------------------------------------------
Aviya Erenfeld (2):
      mac80211: refactor monitor representation in sdata
      mac80211: add support for MU-MIMO air sniffer

Bhaktipriya Shridhar (1):
      cfg80211: Remove deprecated create_singlethread_workqueue

Denis Kenzior (1):
      nl80211: Allow GET_INTERFACE dumps to be filtered

Emmanuel Grumbach (2):
      cfg80211: clarify the requirements of .disconnect()
      mac80211: allow using AP_LINK_PS with mac80211-generated TIM IE

Johannes Berg (21):
      mac80211: add support for radiotap timestamp field
      mac80211: send delBA on unexpected BlockAck data frames
      mac80211: send delBA on unexpected BlockAck Request
      mac80211: simplify TDLS RA lookup
      mac80211: remove useless open_count check
      cfg80211: disallow shared key authentication with key index 4
      nl80211: fix connect keys range check
      nl80211: only allow WEP keys during connect command
      cfg80211: wext: only allow WEP keys to be configured before connected
      cfg80211: validate key index better
      cfg80211: reduce connect key caching struct size
      cfg80211: allow connect keys only with default (TX) key
      mac80211: fix possible out-of-bounds access
      mac80211: fix scan completed tracing
      nl80211: always check nla_nest_start() return value
      nl80211: always check nla_put* return values
      mac80211: remove unused assignment
      mac80211: remove pointless chanctx NULL check
      mac80211: remove sta_remove_debugfs driver callback
      cfg80211: remove unnecessary pointer-of
      mac80211_hwsim: statically initialize hwsim_radios list

Luca Coelho (1):
      cfg80211: add helper to find an IE that matches a byte-array

Maxim Altshul (1):
      mac80211: RX BA support for sta max_rx_aggregation_subframes

Rajkumar Manoharan (1):
      mac80211: allow driver to handle packet-loss mechanism

Toke Høiland-Jørgensen (1):
      mac80211: Re-structure aqm debugfs output and keep CoDel stats per txq

 drivers/net/wireless/mac80211_hwsim.c |   3 +-
 include/net/cfg80211.h                |  36 +++++++-
 include/net/ieee80211_radiotap.h      |  21 +++++
 include/net/mac80211.h                |  33 ++++++--
 net/mac80211/agg-rx.c                 |  11 ++-
 net/mac80211/cfg.c                    |  35 ++++++--
 net/mac80211/debugfs.c                | 152 ++++++----------------------------
 net/mac80211/debugfs_netdev.c         |  37 ++++++++-
 net/mac80211/debugfs_sta.c            |  56 ++++++++++++-
 net/mac80211/driver-ops.c             |   2 +-
 net/mac80211/driver-ops.h             |  18 +---
 net/mac80211/ieee80211_i.h            |  11 ++-
 net/mac80211/iface.c                  |  21 +++--
 net/mac80211/main.c                   |   3 +
 net/mac80211/mlme.c                   |  12 ++-
 net/mac80211/pm.c                     |   3 +-
 net/mac80211/rx.c                     |  69 ++++++++++++++-
 net/mac80211/scan.c                   |   2 +-
 net/mac80211/sta_info.c               |   5 +-
 net/mac80211/sta_info.h               |   3 +
 net/mac80211/status.c                 |   8 +-
 net/mac80211/tx.c                     |  21 ++---
 net/mac80211/util.c                   |   3 +-
 net/wireless/core.c                   |   2 +-
 net/wireless/core.h                   |   6 +-
 net/wireless/ibss.c                   |  11 +--
 net/wireless/mlme.c                   |   2 +-
 net/wireless/nl80211.c                |  85 ++++++++++++++++---
 net/wireless/scan.c                   |  58 ++++++-------
 net/wireless/sme.c                    |   3 +
 net/wireless/sysfs.c                  |   2 +-
 net/wireless/util.c                   |  13 +--
 net/wireless/wext-compat.c            |   9 +-
 net/wireless/wext-sme.c               |   5 +-
 34 files changed, 484 insertions(+), 277 deletions(-)
