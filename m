From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 3/10] hostap: Disable interrupts before Genesis mode
Date: Sat, 12 Mar 2005 16:30:51 -0800
Message-ID: <20050313003051.GD8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Disable interrupts before trying to initialize card after Genesis mode
download. This seems to be required at least with SanDisk ConnectPlus,
but seems to be a good idea in generic, so just do it with all cards.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_download.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_download.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_download.c	2005-03-12 16:10:52.000000000 -0800
@@ -464,6 +464,11 @@
 	local->hw_downloading = 0;
 
 	PDEBUG(DEBUG_EXTRA2, "Trying to initialize card\n");
+	/*
+	 * Make sure the INIT command does not generate a command completion
+	 * event by disabling interrupts.
+	 */
+	hfa384x_disable_interrupts(dev);
 	if (prism2_hw_init(dev, 1)) {
 		printk(KERN_DEBUG "%s: Initialization after genesis mode "
 		       "download failed\n", dev->name);


-- 
Jouni Malinen                                            PGP id EFC895FA
