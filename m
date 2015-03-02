From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 2/2] mesh_plink: fixup type of timeout to match usage
Date: Mon,  2 Mar 2015 04:54:14 -0500
Message-ID: <1425290054-26631-2-git-send-email-hofrat@osadl.org>
References: <1425290054-26631-1-git-send-email-hofrat@osadl.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425290054-26631-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

timeout was being passed as int but assigned from u32/u16 values and used 
as unsigned type. This is really only for better readability.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

After review of the use locations of mesh_plink_timer_set() and declarations 
in sta_info.h this should not be breaking any integer promotions.

This patch applies on top of 
"[PATCH 1/2] mesh_plink: use msecs_to_jiffies for proper time conversion"

Patch was only compile tested with x86_64_defconfig + CONFIG_MAC80211_MESH=y

Patch is against 4.0-rc1 (localversion-next is -next-20150302)

 net/mac80211/mesh_plink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 4eefd5d..8465c05 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -621,7 +621,7 @@ static void mesh_plink_timer(unsigned long data)
 				    sta->llid, sta->plid, reason);
 }
 
-static inline void mesh_plink_timer_set(struct sta_info *sta, int timeout)
+static inline void mesh_plink_timer_set(struct sta_info *sta, u32 timeout)
 {
 	sta->plink_timer.expires = jiffies + msecs_to_jiffies(timeout);
 	sta->plink_timer.data = (unsigned long) sta;
-- 
1.7.10.4
