From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: wireless: marvell: libertas: constify cfg80211_ops structures
Date: Sun, 18 Dec 2016 04:27:24 +0530
Message-ID: <1482015444-28899-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, kvalo@codeaurora.org,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cfg80211_ops structures are only passed as an argument to the function
wiphy_new. This argument is of type const, so cfg80211_ops strutures
having this property can be declared as const.
Done using Coccinelle

@r1 disable optional_qualifier @
identifier i;
position p;
@@
static struct cfg80211_ops i@p = {...};

@ok1@
identifier r1.i;
position p;
@@
wiphy_new(&i@p,...)

@bad@
position p!={r1.p,ok1.p};
identifier r1.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r1.i;
@@
+const
struct cfg80211_ops i;

File size before:
   text	   data	    bss	    dec	    hex	filename
  21225	   1954	     16	  23195	   5a9b	wireless/marvell/libertas/cfg.o

File size after:
   text	   data	    bss	    dec	    hex	filename
  22041	   1154	     16	  23211	   5aab	wireless/marvell/libertas/cfg.o

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/marvell/libertas/cfg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas/cfg.c b/drivers/net/wireless/marvell/libertas/cfg.c
index 7ff2efa..3f97acb 100644
--- a/drivers/net/wireless/marvell/libertas/cfg.c
+++ b/drivers/net/wireless/marvell/libertas/cfg.c
@@ -2086,7 +2086,7 @@ static int lbs_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
  * Initialization
  */
 
-static struct cfg80211_ops lbs_cfg80211_ops = {
+static const struct cfg80211_ops lbs_cfg80211_ops = {
 	.set_monitor_channel = lbs_cfg_set_monitor_channel,
 	.libertas_set_mesh_channel = lbs_cfg_set_mesh_channel,
 	.scan = lbs_cfg_scan,
-- 
1.9.1
