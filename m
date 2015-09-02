From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: [PATCH] cfg80211: regulatory: restore proper user alpha2
Date: Wed, 02 Sep 2015 19:00:31 +0200
Message-ID: <55E72B2F.0@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

restore_regulatory_settings() should restore alpha2
as computed in restore_alpha2(), not raw user_alpha2 to
behave as described in the comment just above that code.

This fixes endless loop of calling CRDA for "00" and "97"
countries after resume from suspend on my laptop.

Looks like others had the same problem, too:
http://ath9k-devel.ath9k.narkive.com/knY5W6St/ath9k-and-crda-messages-in-logs
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/899335
https://forum.porteus.org/viewtopic.php?t=4975&p=36436
https://forums.opensuse.org/showthread.php/
483356-Authentication-Regulatory-Domain-issues-ath5k-12-2

Signed-off-by: Maciej Szmigiero <mail@maciej.szmigiero.name>
---
 net/wireless/reg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 70aef72..7258246 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2625,7 +2625,7 @@ static void restore_regulatory_settings(bool reset_user)
 	 * settings, user regulatory settings takes precedence.
 	 */
 	if (is_an_alpha2(alpha2))
-		regulatory_hint_user(user_alpha2, NL80211_USER_REG_HINT_USER);
+		regulatory_hint_user(alpha2, NL80211_USER_REG_HINT_USER);
 
 	spin_lock(&reg_requests_lock);
 	list_splice_tail_init(&tmp_reg_req_list, &reg_requests_list);
