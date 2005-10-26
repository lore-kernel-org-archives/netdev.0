From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] kill massive wireless-related log spam
Date: Wed, 26 Oct 2005 00:28:27 -0400
Message-ID: <20051026042827.GA22836@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jketreno@linux.intel.com, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932539AbVJZE23@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please apply to 2.6.14-rc.

Although this message is having the intended effect of causing wireless
driver maintainers to upgrade their code, I never should have merged
this patch in its present form.  Leading to tons of bug reports and
unhappy users.

Some wireless apps poll for statistics regularly, which leads to a
printk() every single time they ask for stats.  That's a little bit
_too_ much of a reminder that the driver is using an old API.

Change this to printing out the message once, per kernel boot.

diff --git a/net/core/wireless.c b/net/core/wireless.c
index d17f158..271ddb3 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -455,10 +455,15 @@ static inline struct iw_statistics *get_
 
 	/* Old location, field to be removed in next WE */
 	if(dev->get_wireless_stats) {
-		printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
-		       dev->name);
+		static int printed_message;
+
+		if (!printed_message++)
+			printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
+				dev->name);
+
 		return dev->get_wireless_stats(dev);
 	}
+
 	/* Not found */
 	return (struct iw_statistics *) NULL;
 }
