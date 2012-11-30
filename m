From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-11-30
Date: Fri, 30 Nov 2012 13:25:00 -0500
Message-ID: <20121130182459.GB2355@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 9f8933e960f98d27742727445061b0ece934e5cf

Dave,

I have a couple of stragglers intended for 3.7...

The iwlwifi patch fixes a bug in CCK basic rate calculations.

The mac80211 patch removes an unnecessary function call that was
generating a lot of log SPAM.

Please let me know if there are problems!

John

---

The following changes since commit e196c0e579902f42cf72414461fb034e5a1ffbf7:

  bonding: fix race condition in bonding_store_slaves_active (2012-11-29 13:13:15 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to 9f8933e960f98d27742727445061b0ece934e5cf:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2012-11-30 11:27:32 -0500)

----------------------------------------------------------------

Emmanuel Grumbach (1):
      iwlwifi: fix the basic CCK rates calculation

Johannes Berg (1):
      mac80211: fix remain-on-channel (non-)cancelling

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

 drivers/net/wireless/iwlwifi/dvm/rxon.c | 12 ++++++------
 net/mac80211/offchannel.c               |  2 --
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/rxon.c b/drivers/net/wireless/iwlwifi/dvm/rxon.c
index 1089639..2830ea2 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rxon.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rxon.c
@@ -1012,12 +1012,12 @@ static void iwl_calc_basic_rates(struct iwl_priv *priv,
 	 * As a consequence, it's not as complicated as it sounds, just add
 	 * any lower rates to the ACK rate bitmap.
 	 */
-	if (IWL_RATE_11M_INDEX < lowest_present_ofdm)
-		ofdm |= IWL_RATE_11M_MASK >> IWL_FIRST_CCK_RATE;
-	if (IWL_RATE_5M_INDEX < lowest_present_ofdm)
-		ofdm |= IWL_RATE_5M_MASK >> IWL_FIRST_CCK_RATE;
-	if (IWL_RATE_2M_INDEX < lowest_present_ofdm)
-		ofdm |= IWL_RATE_2M_MASK >> IWL_FIRST_CCK_RATE;
+	if (IWL_RATE_11M_INDEX < lowest_present_cck)
+		cck |= IWL_RATE_11M_MASK >> IWL_FIRST_CCK_RATE;
+	if (IWL_RATE_5M_INDEX < lowest_present_cck)
+		cck |= IWL_RATE_5M_MASK >> IWL_FIRST_CCK_RATE;
+	if (IWL_RATE_2M_INDEX < lowest_present_cck)
+		cck |= IWL_RATE_2M_MASK >> IWL_FIRST_CCK_RATE;
 	/* 1M already there or needed so always add */
 	cck |= IWL_RATE_1M_MASK >> IWL_FIRST_CCK_RATE;
 
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index 83608ac..2c84185 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -458,8 +458,6 @@ void ieee80211_roc_purge(struct ieee80211_sub_if_data *sdata)
 		list_move_tail(&roc->list, &tmp_list);
 		roc->abort = true;
 	}
-
-	ieee80211_start_next_roc(local);
 	mutex_unlock(&local->mtx);
 
 	list_for_each_entry_safe(roc, tmp, &tmp_list, list) {
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
