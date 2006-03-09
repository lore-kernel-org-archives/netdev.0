From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] hostap_hw.c:hfa384x_set_rid(): fix error handling
Date: Fri, 10 Mar 2006 00:06:46 +0100
Message-ID: <20060309230646.GI21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hostap@shmoo.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750773AbWCIXGs@vger.kernel.org>
To: jkmaline@cc.hut.fi
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker noted that the call to prism2_hw_reset() was dead 
code.

Does this patch change the code to what was intended?


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc5-mm3-full/drivers/net/wireless/hostap/hostap_hw.c.old	2006-03-09 23:28:30.000000000 +0100
+++ linux-2.6.16-rc5-mm3-full/drivers/net/wireless/hostap/hostap_hw.c	2006-03-09 23:30:19.000000000 +0100
@@ -928,16 +928,16 @@ static int hfa384x_set_rid(struct net_de
 
 	res = hfa384x_cmd(dev, HFA384X_CMDCODE_ACCESS_WRITE, rid, NULL, NULL);
 	up(&local->rid_bap_sem);
+
 	if (res) {
+		if (res == -ETIMEDOUT)
+			prism2_hw_reset(dev);
+
 		printk(KERN_DEBUG "%s: hfa384x_set_rid: CMDCODE_ACCESS_WRITE "
 		       "failed (res=%d, rid=%04x, len=%d)\n",
 		       dev->name, res, rid, len);
-		return res;
 	}
 
-	if (res == -ETIMEDOUT)
-		prism2_hw_reset(dev);
-
 	return res;
 }
 
