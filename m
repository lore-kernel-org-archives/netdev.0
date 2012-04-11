From: greearb@candelatech.com
Subject: [PATCH 00/10] Wireless patches for wireless-testing
Date: Wed, 11 Apr 2012 10:52:08 -0700
Message-ID: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40888 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab2DKRwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:52:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Support Ethtool stats for Wireless, including in-depth
stats for ath9k, and add some additional ath9k stats
to debugfs.  Support scanning on-channel.

The basic ethtool patches are little changed from previous
posted patches.  The others are tweaked at least some, and
some have not been posted before at all.

Ben Greear (10):
  cfg80211: Add framework to support ethtool stats.
  mac80211: Support getting sta_info stats via ethtool.
  mac80211: Framework to get wifi-driver stats via ethtool.
  ath9k: Support ethtool getstats api.
  mac80211: Add more ethtools stats: survey, rates, etc
  mac80211: Add sta_state to ethtool stats.
  ath9k: Add tx-failed counter.
  mac80211: Support on-channel scan option.
  ath9k: Add more recv stats.
  ath9k: Gather and report IRQ sync_cause errors.

 drivers/net/wireless/ath/ath9k/ar9002_mac.c |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.c |    2 +
 drivers/net/wireless/ath/ath9k/debug.c      |  167 ++++++++++++++-------------
 drivers/net/wireless/ath/ath9k/debug.h      |   43 +++++++
 drivers/net/wireless/ath/ath9k/hw.c         |   49 ++++++++
 drivers/net/wireless/ath/ath9k/hw.h         |    6 +
 drivers/net/wireless/ath/ath9k/main.c       |  135 +++++++++++++++++++++
 drivers/net/wireless/ath/ath9k/recv.c       |   35 ++++--
 include/net/cfg80211.h                      |   17 +++
 include/net/mac80211.h                      |   17 +++
 net/mac80211/cfg.c                          |  160 +++++++++++++++++++++++++
 net/mac80211/driver-ops.h                   |   37 ++++++
 net/mac80211/driver-trace.h                 |   15 +++
 net/mac80211/ieee80211_i.h                  |    3 +
 net/mac80211/main.c                         |    4 +-
 net/mac80211/rx.c                           |    2 +
 net/mac80211/scan.c                         |   92 +++++++++++-----
 net/wireless/ethtool.c                      |   29 +++++
 18 files changed, 695 insertions(+), 119 deletions(-)

-- 
1.7.3.4
