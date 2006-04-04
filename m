From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/core/net-sysfs.c: fix an off-by-21-or-49 error
Date: Tue, 4 Apr 2006 21:07:42 +0200
Message-ID: <20060404190742.GA6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750811AbWDDTHp@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes an off-by-21-or-49 error ;-) spotted by the Coverity 
checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-rc1-mm1-full/net/core/net-sysfs.c.old	2006-04-04 20:36:32.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/net/core/net-sysfs.c	2006-04-04 20:36:49.000000000 +0200
@@ -165,7 +165,7 @@ static ssize_t show_operstate(struct cla
 		operstate = IF_OPER_DOWN;
 	read_unlock(&dev_base_lock);
 
-	if (operstate >= sizeof(operstates))
+	if (operstate >= ARRAY_SIZE(operstates))
 		return -EINVAL; /* should not happen */
 
 	return sprintf(buf, "%s\n", operstates[operstate]);
