From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make hdlc_setup() static again
Date: Thu, 11 Jan 2007 14:48:59 +0100
Message-ID: <20070111134859.GD20027@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:4598 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030449AbXAKNsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 08:48:55 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hdlc_setup was exported, but this export was never used.

If a driver using it actually shows up it can still be exported again.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: Krzysztof Halasa <khc@pm.waw.pl>

---

This patch was already sent on:
- 25 Nov 2006

--- linux-2.6.19-rc6-mm1/drivers/net/wan/hdlc.c.old	2006-11-25 00:16:13.000000000 +0100
+++ linux-2.6.19-rc6-mm1/drivers/net/wan/hdlc.c	2006-11-25 00:16:26.000000000 +0100
@@ -222,7 +222,7 @@
 	return -EINVAL;
 }
 
-void hdlc_setup(struct net_device *dev)
+static void hdlc_setup(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 
@@ -325,7 +325,6 @@
 EXPORT_SYMBOL(hdlc_open);
 EXPORT_SYMBOL(hdlc_close);
 EXPORT_SYMBOL(hdlc_ioctl);
-EXPORT_SYMBOL(hdlc_setup);
 EXPORT_SYMBOL(alloc_hdlcdev);
 EXPORT_SYMBOL(unregister_hdlc_device);
 EXPORT_SYMBOL(register_hdlc_protocol);

