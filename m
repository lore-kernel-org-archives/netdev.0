From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH] pcmcia: xirc2ps_cs bugfix
Date: Fri, 13 Aug 2010 20:56:23 +0200
Message-ID: <20100813185623.GC5853@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Komuro <komurojun-mbn@nifty.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:52709 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762079Ab0HMTZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 15:25:15 -0400
Content-Disposition: attachment
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus,

could you apply the attached bugfix for PCMCIA, please? Alternatively,
please pull from 

git://git.kernel.org/pub/scm/linux/kernel/git/brodo/pcmcia-2.6.git master

where this one patch is located. What do you prefer, actually, if it is just
one patch I want to push to you?

Thanks & best,

	Dominik

---
From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Fri, 13 Aug 2010 20:33:34 +0200
Subject: [PATCH] pcmcia: xirc2ps_cs bugfix

We need to set io_lines to 10 unconditionally.

Reported-by: Komuro <komurojun-mbn@nifty.com>
CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 4eb6f98..f581952 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -808,6 +808,7 @@ xirc2ps_config(struct pcmcia_device * link)
     }
 
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;
+    link->io_lines = 10;
     if (local->modem) {
 	int pass;
 
@@ -839,7 +840,6 @@ xirc2ps_config(struct pcmcia_device * link)
 	}
 	printk(KNOT_XIRC "no ports available\n");
     } else {
-	link->io_lines = 10;
 	link->resource[0]->end = 16;
 	for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
 	    link->resource[0]->start = ioaddr;
