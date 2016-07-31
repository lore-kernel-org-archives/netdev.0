From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: ethernet: ax88796: avoid null pointer dereference
Date: Sun, 31 Jul 2016 09:58:44 +0200
Message-ID: <1469951924-20276-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:51079 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbcGaIFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 04:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If platform_get_resource fails, mem2 is null.
Do not dereference null.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/8390/ax88796.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 5698f53..39ca935 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -910,7 +910,8 @@ static int ax_probe(struct platform_device *pdev)
 	iounmap(ax->map2);
 
  exit_mem2:
-	release_mem_region(mem2->start, mem2_size);
+	if (mem2)
+		release_mem_region(mem2->start, mem2_size);
 
  exit_mem1:
 	iounmap(ei_local->mem);
-- 
2.8.1
