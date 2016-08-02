From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0784/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:46:01 +0800
Message-ID: <20160802114601.2011-1-baolex.ni@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, a@unstable.cc, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
	Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org, m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/mac80211_hwsim.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 4dd5adc..ad82480 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -42,23 +42,23 @@ MODULE_LICENSE("GPL");
 static u32 wmediumd_portid;
 
 static int radios = 2;
-module_param(radios, int, 0444);
+module_param(radios, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(radios, "Number of simulated radios");
 
 static int channels = 1;
-module_param(channels, int, 0444);
+module_param(channels, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(channels, "Number of concurrent channels");
 
 static bool paged_rx = false;
-module_param(paged_rx, bool, 0644);
+module_param(paged_rx, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(paged_rx, "Use paged SKBs for RX instead of linear ones");
 
 static bool rctbl = false;
-module_param(rctbl, bool, 0444);
+module_param(rctbl, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rctbl, "Handle rate control table");
 
 static bool support_p2p_device = true;
-module_param(support_p2p_device, bool, 0444);
+module_param(support_p2p_device, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(support_p2p_device, "Support P2P-Device interface type");
 
 /**
@@ -134,7 +134,7 @@ enum hwsim_regtest {
 
 /* Set to one of the HWSIM_REGTEST_* values above */
 static int regtest = HWSIM_REGTEST_DISABLED;
-module_param(regtest, int, 0444);
+module_param(regtest, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(regtest, "The type of regulatory test we want to run");
 
 static const char *hwsim_alpha2s[] = {
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
