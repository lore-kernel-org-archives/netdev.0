From: Mariusz Kozlowski <mk@lab.zgora.pl>
Subject: [PATCH] mac80211: fix possible NULL pointer dereference
Date: Sat, 26 Mar 2011 18:58:51 +0100
Message-ID: <1301162331-5236-1-git-send-email-mk@lab.zgora.pl>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mariusz Kozlowski <mk@lab.zgora.pl>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves 'key' dereference after BUG_ON(!key) so that when key is NULL
we will see proper trace instead of oops.

Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
---
 net/mac80211/key.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 8c02469..fd97925 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -400,11 +400,12 @@ int ieee80211_key_link(struct ieee80211_key *key,
 {
 	struct ieee80211_key *old_key;
 	int idx, ret;
-	bool pairwise = key->conf.flags & IEEE80211_KEY_FLAG_PAIRWISE;
+	bool pairwise;
 
 	BUG_ON(!sdata);
 	BUG_ON(!key);
 
+	pairwise = key->conf.flags & IEEE80211_KEY_FLAG_PAIRWISE;
 	idx = key->conf.keyidx;
 	key->local = sdata->local;
 	key->sdata = sdata;
-- 
1.7.0.4
