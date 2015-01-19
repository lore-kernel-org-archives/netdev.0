From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-01-19
Date: Mon, 19 Jan 2015 19:06:22 +0100
Message-ID: <1421690782.1965.43.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35717 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbbASSGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 13:06:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please excuse the quick succession of pull requests - two issues were
found in the code from the previous one that we'd like to fix quickly,
along with less than a handful of other changes described below.

Thanks,
johannes

The following changes since commit baf1b99ba169bdd3324ac9d99bc2a00c25534429:

  cfg80211: docs: remove station_info_flags (2015-01-14 13:57:36 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-01-19

for you to fetch changes up to c1e140bf79d817d4a7aa9932eb98b0359c87af33:

  mac80211: delete the assoc/auth timer upon suspend (2015-01-19 18:59:20 +0100)

----------------------------------------------------------------
Some further updates for net-next:
 * fix network-manager which was broken by the previous changes
 * fix delete-station events, which were broken by me making the
   genlmsg_end() mistake
 * fix a timer left running during suspend in some race conditions
   that would cause an annoying (but harmless) warning
 * (less important, but in the tree already) remove 80+80 MHz rate
   reporting since the spec doesn't distinguish it from 160 MHz;
   as the bitrate they're both 160 MHz bandwidth

----------------------------------------------------------------
Emmanuel Grumbach (1):
      mac80211: delete the assoc/auth timer upon suspend

Johannes Berg (6):
      mac80211: remove 80+80 MHz rate reporting
      cfg80211: remove 80+80 MHz rate reporting
      cfg80211: change bandwidth reporting to explicit field
      mac80211: remove doubled semicolon
      cfg80211: fix checking nl80211_send_station() return value
      Revert "wireless: Support of IFLA_INFO_KIND rtnl attribute"

 drivers/net/wireless/ath/ath6kl/cfg80211.c |  3 +-
 drivers/net/wireless/mwifiex/cfg80211.c    | 11 ++++----
 include/net/cfg80211.h                     | 35 ++++++++++++++++-------
 include/net/mac80211.h                     |  6 ++--
 include/uapi/linux/nl80211.h               | 11 +++++++-
 net/mac80211/cfg.c                         | 33 +++++++++++++---------
 net/mac80211/mlme.c                        | 12 ++++++++
 net/mac80211/rx.c                          |  5 ----
 net/mac80211/status.c                      |  2 +-
 net/mac80211/util.c                        | 27 +++++++++++-------
 net/wireless/core.c                        |  6 ----
 net/wireless/nl80211.c                     | 45 +++++++++++++++++++-----------
 net/wireless/util.c                        | 25 +++++++++++++----
 13 files changed, 143 insertions(+), 78 deletions(-)
