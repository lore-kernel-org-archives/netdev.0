From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0772/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:55 +0800
Message-ID: <20160802114455.1141-1-baolex.ni@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org,
	johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	bkenward-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org, m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
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
 drivers/net/wireless/broadcom/b43legacy/main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43legacy/main.c b/drivers/net/wireless/broadcom/b43legacy/main.c
index 83770d2..a3303cd 100644
--- a/drivers/net/wireless/broadcom/b43legacy/main.c
+++ b/drivers/net/wireless/broadcom/b43legacy/main.c
@@ -65,7 +65,7 @@ MODULE_FIRMWARE("b43legacy/ucode4.fw");
 
 #if defined(CONFIG_B43LEGACY_DMA) && defined(CONFIG_B43LEGACY_PIO)
 static int modparam_pio;
-module_param_named(pio, modparam_pio, int, 0444);
+module_param_named(pio, modparam_pio, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(pio, "enable(1) / disable(0) PIO mode");
 #elif defined(CONFIG_B43LEGACY_DMA)
 # define modparam_pio	0
@@ -74,12 +74,12 @@ MODULE_PARM_DESC(pio, "enable(1) / disable(0) PIO mode");
 #endif
 
 static int modparam_bad_frames_preempt;
-module_param_named(bad_frames_preempt, modparam_bad_frames_preempt, int, 0444);
+module_param_named(bad_frames_preempt, modparam_bad_frames_preempt, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bad_frames_preempt, "enable(1) / disable(0) Bad Frames"
 		 " Preemption");
 
 static char modparam_fwpostfix[16];
-module_param_string(fwpostfix, modparam_fwpostfix, 16, 0444);
+module_param_string(fwpostfix, modparam_fwpostfix, 16, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fwpostfix, "Postfix for the firmware files to load.");
 
 /* The following table supports BCM4301, BCM4303 and BCM4306/2 devices. */
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
