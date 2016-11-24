From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/4] mac80211: Removed unused 'struct
 ieee80211_supported_band*' variable
Date: Wed, 23 Nov 2016 20:46:14 -0800
Message-ID: <a8fcdffb1e209afc5148bec8ba6229fcc8dd50af.1479962513.git.kirtika@chromium.org>
References: <cover.1479962513.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Marek Kwaczynski <marek.kwaczynski-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        David Spinadel <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Alexander Bondar <alexander.bondar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1479962513.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit b1bce14a7954 (mac80211: update opmode when adding new station)
refactored ieee80211_vht_handle_opmode into __ieee80211_vht_handle_opmode
and ieee80211_vht_handle_opmode leaving a set but unused variable
(sband) in the former. Compiling with W=1 gives the following warning,
fix it.

net/mac80211/vht.c: In function ‘__ieee80211_vht_handle_opmode’:
net/mac80211/vht.c:424:35: warning: variable ‘sband’ set but not used [-Wunused-but-set-variable]

Remove 'struct ieee80211_local* local' as well, it was only used to
set sband.

This is a harmless warning, and is only being fixed to reduce the
noise with W=1 in the kernel.

Fixes: b1bce14a7954 ("mac80211: update opmode when adding new station")
Cc: Marek Kwaczynski <marek.kwaczynski-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 net/mac80211/vht.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/mac80211/vht.c b/net/mac80211/vht.c
index ee71576..14920e3 100644
--- a/net/mac80211/vht.c
+++ b/net/mac80211/vht.c
@@ -420,14 +420,10 @@ u32 __ieee80211_vht_handle_opmode(struct ieee80211_sub_if_data *sdata,
 				  struct sta_info *sta, u8 opmode,
 				  enum nl80211_band band)
 {
-	struct ieee80211_local *local = sdata->local;
-	struct ieee80211_supported_band *sband;
 	enum ieee80211_sta_rx_bandwidth new_bw;
 	u32 changed = 0;
 	u8 nss;
 
-	sband = local->hw.wiphy->bands[band];
