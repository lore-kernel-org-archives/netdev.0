From: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] mac80211: Fix clang warning about constant operand in logical operation
Date: Thu,  6 Apr 2017 11:56:33 -0700
Message-ID: <20170406185633.91065-1-mka@chromium.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Michael Davidson <md-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Greg Hackmann <ghackmann-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Clang raises a warning about the expression 'strlen(CONFIG_XXX)' being
used in a logical operation. Clangs' builtin strlen function resolves the
expression to a constant at compile time, which causes clang to generate
a 'constant-logical-operand' warning.

Split the if statement in two to avoid using the const expression in a
logical operation.

Signed-off-by: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 net/mac80211/rate.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 206698bc93f4..68ff202d6380 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -173,9 +173,14 @@ ieee80211_rate_control_ops_get(const char *name)
 		/* try default if specific alg requested but not found */
 		ops = ieee80211_try_rate_control_ops_get(ieee80211_default_rc_algo);
 
+	if (ops)
+		goto unlock;
+
 	/* try built-in one if specific alg requested but not found */
-	if (!ops && strlen(CONFIG_MAC80211_RC_DEFAULT))
+	if (strlen(CONFIG_MAC80211_RC_DEFAULT))
 		ops = ieee80211_try_rate_control_ops_get(CONFIG_MAC80211_RC_DEFAULT);
+
+unlock:
 	kernel_param_unlock(THIS_MODULE);
 
 	return ops;
-- 
2.12.2.715.g7642488e1d-goog
