From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net/m68k: Hydra Ethernet - print whole resource instead of
 start address
Date: Mon, 30 Aug 2010 09:43:46 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1008300942560.30729@ayla.of.borg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux/m68k <linux-m68k@lists.linux-m68k.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:46671 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab0H3Hns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 03:43:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

resource_size_t changed from `unsigned long' to `phys_addr_t`, which is either
`u32' or `u64'.
Print the whole resource to remove the cast and to make it future-proof.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/hydra.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hydra.c b/drivers/net/hydra.c
index 07d8e5b..7eb0e78 100644
--- a/drivers/net/hydra.c
+++ b/drivers/net/hydra.c
@@ -173,9 +173,8 @@ static int __devinit hydra_init(struct zorro_dev *z)
 
     zorro_set_drvdata(z, dev);
 
-    printk(KERN_INFO "%s: Hydra at 0x%08llx, address "
-	   "%pM (hydra.c " HYDRA_VERSION ")\n",
-	   dev->name, (unsigned long long)z->resource.start, dev->dev_addr);
+    pr_info("%s: Hydra at %pR, address %pM (hydra.c " HYDRA_VERSION ")\n",
+	    dev->name, &z->resource, dev->dev_addr);
 
     return 0;
 }
-- 
1.7.0.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
