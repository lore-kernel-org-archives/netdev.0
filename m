From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] drivers/net/wireless/ipw2200.c: remove division by zero
Date: Sat, 9 Jul 2005 05:07:13 +0200
Message-ID: <20050709030713.GA28243@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ipw2100-admin@linux.intel.com, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263097AbVGIDHW@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc correctly complained about a division by zero for HZ < 1000.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 2 Jul 2005

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
