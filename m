From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2015-04-10
Date: Fri, 10 Apr 2015 13:18:58 +0200
Message-ID: <1428664738.1890.12.camel@sipsolutions.net>
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

I realize it's late, but what I've got right now has so many fixes that
I'd be sending even after the merge window, so it felt like there was
little point in holding it up until after then. The new "intermediate
queue" feature is unused right now so seems safe enough also, and having
it in will help modify drivers to use it.
There's also some rate control refactoring that, as far as I can tell,
is uncontroversial and over the last couple of weeks has been has been
reviewed and tested by people who use it, so I'm including it.

Let me know if you want me to change anything here or if there are any
other problems.

Thanks,
johannes

The following changes since commit 9911674fcf1f239ff3c87e56177c4826e33dfd95:

  Merge branch 'ptp-ns_to_timespec64' (2015-03-31 17:19:19 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-04-10

for you to fetch changes up to 6d00ec0514bd909e89ede59501342732dbef49fd:

  cfg80211: don't allow disabling WEXT if it's required (2015-04-08 09:19:29 +0200)

----------------------------------------------------------------
There isn't much left, but we have
 * new mac80211 internal software queue to allow drivers to have
   shorter hardware queues and pull on-demand
 * use rhashtable for mac80211 station table
 * minstrel rate control debug improvements and some refactoring
 * fix noisy message about TX power reduction
 * fix continuous message printing and activity if CRDA doesn't respond
 * fix VHT-related capabilities with "iw connect" or "iwconfig ..."
 * fix Kconfig for cfg80211 wireless extensions compatibility

----------------------------------------------------------------
Felix Fietkau (1):
      mac80211: add an intermediate software queue implementation

Ilan peer (1):
      cfg80211: Stop calling crda if it is not responsive

Johannes Berg (4):
      mac80211: use rhashtable for station table
      cfg80211: move IE split utilities here from mac80211
      cfg80211: send extended capabilities IE in connect
      cfg80211: don't allow disabling WEXT if it's required

John Linville (1):
      mac80211: reduce log spam from ieee80211_handle_pwr_constr

Thomas Huehn (10):
      mac80211: enhance readability of Minstrels rc_stats output
      mac80211: enhance readability of Minstrel-HTs rc_stats output
      mac80211: add new Minstrel statistic output via csv
      mac80211: add new Minstrel-HT statistic output via csv
      mac80211: unify Minstrel & Minstrel-HTs calculation of rate statistics
      mac80211: improve Minstrel variable & function naming
      mac80211: restructure per-rate throughput calculation into function
      mac80211: add max lossless throughput per rate
      mac80211: reduce calculation costs of EWMA
      mac80211: add standard deviation to Minstrel stats

 include/net/cfg80211.h                     |  58 ++++++++
 include/net/mac80211.h                     | 101 +++++++++++---
 net/mac80211/agg-tx.c                      |  44 ++++++
 net/mac80211/driver-ops.h                  |  12 ++
 net/mac80211/ieee80211_i.h                 |  28 +++-
 net/mac80211/iface.c                       |  23 ++-
 net/mac80211/main.c                        |  12 +-
 net/mac80211/mlme.c                        |  14 +-
 net/mac80211/rc80211_minstrel.c            | 125 +++++++++++------
 net/mac80211/rc80211_minstrel.h            |  49 +++++--
 net/mac80211/rc80211_minstrel_debugfs.c    | 125 ++++++++++++++---
 net/mac80211/rc80211_minstrel_ht.c         | 217 ++++++++++++++---------------
 net/mac80211/rc80211_minstrel_ht.h         |   5 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c | 216 ++++++++++++++++++++++++----
 net/mac80211/rx.c                          |  22 ++-
 net/mac80211/sta_info.c                    | 186 +++++++++++++++++--------
 net/mac80211/sta_info.h                    |  40 ++----
 net/mac80211/status.c                      |   8 +-
 net/mac80211/trace.h                       |  31 +++++
 net/mac80211/tx.c                          | 115 +++++++++++++--
 net/mac80211/util.c                        |  62 +++------
 net/wireless/Kconfig                       |   2 +-
 net/wireless/nl80211.c                     |   2 +-
 net/wireless/reg.c                         |  34 ++++-
 net/wireless/reg.h                         |   9 +-
 net/wireless/sme.c                         |  74 ++++++++--
 net/wireless/util.c                        |  41 ++++++
 27 files changed, 1249 insertions(+), 406 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
