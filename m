From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-09-07
Date: Thu,  7 Sep 2017 09:09:38 +0200
Message-ID: <20170907070939.3658-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40654 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbdIGHJn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 03:09:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

During my long absence some things have accumulated, but there wasn't
actually all that much that could've gone into the last cycle, and a
fix or two was taken care of by others.

The most important thing here is probably the deadlock fix that a few
people have run into on 4.13, but that was only identified now, and
perhaps the 40 MHz fix from Emmanuel that helps avoid iwlwifi firmware
crashes.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 6d9c153a0b84392406bc77600aa7d3ea365de041:

  net: dsa: loop: Do not unregister invalid fixed PHY (2017-09-03 20:18:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-09-07

for you to fetch changes up to bde59c475e0883e4c4294bcd9b9c7e08ae18c828:

  mac80211: fix deadlock in driver-managed RX BA session start (2017-09-06 15:22:02 +0200)

----------------------------------------------------------------
Back from a long absence, so we have a number of things:
 * a remain-on-channel fix from Avi
 * hwsim TX power fix from Beni
 * null-PTR dereference with iTXQ in some rare configurations (Chunho)
 * 40 MHz custom regdomain fixes (Emmanuel)
 * look at right place in HT/VHT capability parsing (Igor)
 * complete A-MPDU teardown properly (Ilan)
 * Mesh ID Element ordering fix (Liad)
 * avoid tracing warning in ht_dbg() (Sharon)
 * fix print of assoc/reassoc (Simon)
 * fix encrypted VLAN with iTXQ (myself)
 * fix calling context of TX queue wake (myself)
 * fix a deadlock with ath10k aggregation (myself)

----------------------------------------------------------------
Avraham Stern (1):
      mac80211: flush hw_roc_start work before cancelling the ROC

Beni Lev (1):
      mac80211_hwsim: Use proper TX power

Chunho Lee (1):
      mac80211: Fix null pointer dereference with iTXQ support

Emmanuel Grumbach (1):
      cfg80211: honor NL80211_RRF_NO_HT40{MINUS,PLUS}

Igor Mitsyanko (1):
      nl80211: look for HT/VHT capabilities in beacon's tail

Ilan peer (1):
      mac80211: Complete ampdu work schedule during session tear down

Johannes Berg (3):
      mac80211: fix VLAN handling with TXQs
      mac80211: agg-tx: call drv_wake_tx_queue in proper context
      mac80211: fix deadlock in driver-managed RX BA session start

Liad Kaufman (1):
      mac80211: add MESH IE in the correct order

Sharon Dvir (1):
      mac80211: shorten debug prints using ht_dbg() to avoid warning

Simon Dinkin (1):
      mac80211: fix incorrect assignment of reassoc value

 drivers/net/wireless/mac80211_hwsim.c |  2 --
 include/net/mac80211.h                | 15 ++-------------
 net/mac80211/agg-rx.c                 | 32 ++++++++++++++++++++-----------
 net/mac80211/agg-tx.c                 |  8 ++++++--
 net/mac80211/ht.c                     | 24 ++++++++++++++++++++---
 net/mac80211/ieee80211_i.h            |  4 ++++
 net/mac80211/iface.c                  | 20 ++++++++++++++++---
 net/mac80211/mlme.c                   |  2 +-
 net/mac80211/offchannel.c             |  2 ++
 net/mac80211/tx.c                     | 36 ++++++++++++++++++++++++++++-------
 net/mac80211/util.c                   |  2 +-
 net/wireless/nl80211.c                |  4 ++--
 net/wireless/reg.c                    | 20 +++++++++++++++++--
 13 files changed, 124 insertions(+), 47 deletions(-)
