From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 4/4] mac80211: Remove unused 'beaconint_us' variable
Date: Wed, 23 Nov 2016 20:46:27 -0800
Message-ID: <9a09ca6fd5eeab860461b1692fdf5274dfa1aee8.1479962513.git.kirtika@chromium.org>
References: <cover.1479962513.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Marek Kwaczynski <marek.kwaczynski@tieto.com>,
        David Spinadel <david.spinadel@intel.com>,
        Alexander Bondar <alexander.bondar@intel.com>,
        Michal Kazior <michal.kazior@tieto.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33266 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754354AbcKXEqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 23:46:32 -0500
Content-Disposition: inline
In-Reply-To: <cover.1479962513.git.kirtika@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4a733ef1bea7 (mac80211: remove PM-QoS listener) removed all use
of 'beaconint_us' from ieee80211_recalc_ps() but left the variable
intact. Compiling with W=1 gives the following warning, fix it.
net/mac80211/mlme.c: In function ‘ieee80211_recalc_ps’:
net/mac80211/mlme.c:1481:7: warning: variable ‘beaconint_us’ set but not used [-Wunused-but-set-variable]

iee80211_tu_to_usec has no side-effects and is safe to remove.

Fixes: 4a733ef1bea7 ("mac80211: remove PM-QoS listener")
Cc: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: Kirtika Ruchandani <kirtika@chromium.org>
---
 net/mac80211/mlme.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 7486f2d..e883345 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1478,10 +1478,6 @@ void ieee80211_recalc_ps(struct ieee80211_local *local)
 
 	if (count == 1 && ieee80211_powersave_allowed(found)) {
 		u8 dtimper = found->u.mgd.dtim_period;
-		s32 beaconint_us;
-
-		beaconint_us = ieee80211_tu_to_usec(
-					found->vif.bss_conf.beacon_int);
 
 		timeout = local->dynamic_ps_forced_timeout;
 		if (timeout < 0)
-- 
2.8.0.rc3.226.g39d4020
