From: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Subject: [PATCH 1/3] wireless: orinoco: orinoco_plx use msecs_to_jiffies for conversion
Date: Wed,  4 Feb 2015 03:07:39 -0500
Message-ID: <1423037261-20193-1-git-send-email-hofrat@osadl.org>
Cc: Benoit Taine <benoit.taine-L2FTfq7BK8M@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable
it replaces var * HZ / 1000 by msecs_to_jiffies(var).

Signed-off-by: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
---

Converting milliseconds to jiffies by "val * HZ / 1000" is technically
ok but msecs_to_jiffies(val) is the cleaner solution and handles all
corner cases correctly. This is a minor API cleanup only.

Patch was compile-tested only for x86_64_defconfig + CONFIG_HERMES=m
CONFIG_PLX_HERMES=m

Patch is against 3.19.0-rc7 (localversion-next is -next-20150203)

 drivers/net/wireless/orinoco/orinoco_plx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/orinoco/orinoco_plx.c b/drivers/net/wireless/orinoco/orinoco_plx.c
index b8f6e5c..8b04523 100644
--- a/drivers/net/wireless/orinoco/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco/orinoco_plx.c
@@ -121,7 +121,7 @@ static int orinoco_plx_cor_reset(struct orinoco_private *priv)
 	mdelay(1);
 
 	/* Just in case, wait more until the card is no longer busy */
-	timeout = jiffies + (PLX_RESET_TIME * HZ / 1000);
+	timeout = jiffies + msecs_to_jiffies(PLX_RESET_TIME);
 	reg = hermes_read_regn(hw, CMD);
 	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
 		mdelay(1);
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
