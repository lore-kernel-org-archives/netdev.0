From: akpm@linux-foundation.org
Subject: [patch (for 2.6.25?) 2/3] de2104x: remove BUG_ON() when changing media type
Date: Tue, 04 Mar 2008 14:58:42 -0800
Message-ID: <200803042258.m24Mwgqn001400@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux@rainbow-software.org, grundler@parisc-linux.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37125 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762128AbYCDW72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:59:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>

When the chip dies (probably because of a bug somewhere in the driver),
de_stop_rxtx() fails and changing the media type crashes the whole machine.
 Replace BUG_ON() in de_set_media() with a warning.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
Cc: Jeff Garzik <jeff@garzik.org>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/de2104x.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/tulip/de2104x.c~de2104x-remove-bug_on-when-changing-media-type drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c~de2104x-remove-bug_on-when-changing-media-type
+++ a/drivers/net/tulip/de2104x.c
@@ -910,7 +910,8 @@ static void de_set_media (struct de_priv
 	unsigned media = de->media_type;
 	u32 macmode = dr32(MacMode);
 
-	BUG_ON(de_is_running(de));
+	if (de_is_running(de))
+		printk(KERN_WARNING "%s: chip is running while changing media!\n", de->dev->name);
 
 	if (de->de21040)
 		dw32(CSR11, FULL_DUPLEX_MAGIC);
_
