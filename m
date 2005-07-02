From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] drivers/net/wireless/ipw2200.c: remove division by zero
Date: Sat, 2 Jul 2005 23:51:11 +0200
Message-ID: <20050702215111.GE5346@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261300AbVGBVwW@vger.kernel.org>
To: ipw2100-admin@linux.intel.com, jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc correctly complained about a division by zero for HZ < 1000.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc1-mm1-full/drivers/net/wireless/ipw2200.c.old	2005-07-02 23:14:39.000000000 +0200
+++ linux-2.6.13-rc1-mm1-full/drivers/net/wireless/ipw2200.c	2005-07-02 23:15:39.000000000 +0200
@@ -1170,7 +1170,7 @@
 		HOST_COMPLETE_TIMEOUT);
 	if (rc == 0) {
 		IPW_DEBUG_INFO("Command completion failed out after %dms.\n",
-			       HOST_COMPLETE_TIMEOUT / (HZ / 1000));
+			       (1000 * HOST_COMPLETE_TIMEOUT) / HZ);
 		priv->status &= ~STATUS_HCMD_ACTIVE;
 		return -EIO;
 	}
