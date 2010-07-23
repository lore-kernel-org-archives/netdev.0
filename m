From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] net: 3c59x: fix leak of iomaps
Date: Fri, 23 Jul 2010 20:44:44 +0400
Message-ID: <1279903485-28247-1-git-send-email-segooon@gmail.com>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:52299 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab0GWQo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 12:44:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vortex_probe1() fails we should unmap ioaddr mapped earlier.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/3c59x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 9b137e1..ebd4c19 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1029,6 +1029,7 @@ static int __devinit vortex_init_one(struct pci_dev *pdev,
 	rc = vortex_probe1(&pdev->dev, ioaddr, pdev->irq,
 			   ent->driver_data, unit);
 	if (rc < 0) {
+		pci_iounmap(pdev, ioaddr);
 		pci_disable_device(pdev);
 		goto out;
 	}
-- 
1.7.0.4

