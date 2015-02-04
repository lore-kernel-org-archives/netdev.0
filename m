From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 3/3] wireless: orinoco: orinoco_tmd use msecs_to_jiffies for conversion
Date: Wed,  4 Feb 2015 03:07:41 -0500
Message-ID: <1423037261-20193-3-git-send-email-hofrat@osadl.org>
References: <1423037261-20193-1-git-send-email-hofrat@osadl.org>
Cc: Benoit Taine <benoit.taine@lip6.fr>,
	Bjorn Helgaas <bhelgaas@google.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423037261-20193-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable
it replaces var * HZ / 1000 by msecs_to_jiffies(var).

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Converting milliseconds to jiffies by "val * HZ / 1000" is technically
ok but msecs_to_jiffies(val) is the cleaner solution and handles all
corner cases correctly. This is a minor API cleanup only.

Patch was compile-tested only for x86_64_defconfig + CONFIG_HERMES=m
CONFIG_TMD_HERMES=m

Patch is against 3.19.0-rc7 (localversion-next is -next-20150203)

 drivers/net/wireless/orinoco/orinoco_tmd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/orinoco/orinoco_tmd.c b/drivers/net/wireless/orinoco/orinoco_tmd.c
index 79d0e33..20ce569 100644
--- a/drivers/net/wireless/orinoco/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco/orinoco_tmd.c
@@ -71,7 +71,7 @@ static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
 	mdelay(1);
 
 	/* Just in case, wait more until the card is no longer busy */
-	timeout = jiffies + (TMD_RESET_TIME * HZ / 1000);
+	timeout = jiffies + msecs_to_jiffies(TMD_RESET_TIME);
 	reg = hermes_read_regn(hw, CMD);
 	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
 		mdelay(1);
-- 
1.7.10.4
