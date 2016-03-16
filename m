From: Michal Kazior <michal.kazior@tieto.com>
Subject: [RFCv2 0/3] mac80211: implement fq codel
Date: Wed, 16 Mar 2016 11:17:55 +0100
Message-ID: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
Cc: ath10k@lists.infradead.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, dave.taht@gmail.com,
	emmanuel.grumbach@intel.com, nbd@openwrt.org,
	Tim Shepard <shep@alum.mit.edu>,
	make-wifi-fast@lists.bufferbloat.net, codel@lists.bufferbloat.net,
	Michal Kazior <michal.kazior@tieto.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:35449 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbcCPKPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 06:15:49 -0400
Received: by mail-lb0-f170.google.com with SMTP id bc4so44630629lbc.2
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 03:15:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Most notable changes:
 * fixes (duh); fairness should work better now,
 * EWMA codel target based on estimated service
   time,
 * new tx scheduling helper with in-flight
   duration limiting (same idea Emmanuel
   had for iwlwifi),
 * added a few debugfs hooks.
 * ath10k proof-of-concept that uses the new tx
   scheduling (will post results in separate
   email)

The patch grew pretty big and I plan on splitting
it before next submission. Any suggestions?

The tx scheduling probably needs more work and
testing. I didn't evaluate how CPU intensive it is
nor how it influences things like peak throughput
(lab conditions et al) yet.

I've uploaded a branch for convenience:

  https://github.com/kazikcz/linux/tree/fqmac-rfc-v2

This is based on Kalle's ath tree.


Michal Kazior (3):
  mac80211: implement fq_codel for software queuing
  ath10k: report per-station tx/rate rates to mac80211
  ath10k: use ieee80211_tx_schedule()

 drivers/net/wireless/ath/ath10k/core.c  |   2 -
 drivers/net/wireless/ath/ath10k/core.h  |   8 +-
 drivers/net/wireless/ath/ath10k/debug.c |  61 ++-
 drivers/net/wireless/ath/ath10k/mac.c   | 126 +++---
 drivers/net/wireless/ath/ath10k/wmi.h   |   2 +-
 include/net/mac80211.h                  |  96 ++++-
 net/mac80211/agg-tx.c                   |   8 +-
 net/mac80211/cfg.c                      |   2 +-
 net/mac80211/codel.h                    | 264 +++++++++++++
 net/mac80211/codel_i.h                  |  89 +++++
 net/mac80211/debugfs.c                  | 267 +++++++++++++
 net/mac80211/ieee80211_i.h              |  45 ++-
 net/mac80211/iface.c                    |  25 +-
 net/mac80211/main.c                     |   9 +-
 net/mac80211/rx.c                       |   2 +-
 net/mac80211/sta_info.c                 |  10 +-
 net/mac80211/sta_info.h                 |  27 ++
 net/mac80211/status.c                   |  64 ++++
 net/mac80211/tx.c                       | 658 ++++++++++++++++++++++++++++++--
 net/mac80211/util.c                     |  21 +-
 20 files changed, 1629 insertions(+), 157 deletions(-)
 create mode 100644 net/mac80211/codel.h
 create mode 100644 net/mac80211/codel_i.h

-- 
2.1.4
