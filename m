From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 2/2] bfin_mac: fix error path
Date: Fri,  8 Jan 2016 16:58:15 +0530
Message-ID: <1452252495-20961-2-git-send-email-sudipm.mukherjee@gmail.com>
References: <1452252495-20961-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33629 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbcAHL20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 06:28:26 -0500
In-Reply-To: <1452252495-20961-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While building blackfin defconfig we were getting a build warning:
warning: label 'out_err_irq_alloc' defined but not used.

Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
removed the label out_err_mdiobus_register but then mistakenly jumped to
out_err_alloc. But it was actually supposed to jump to out_err_irq_alloc.

Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/ethernet/adi/bfin_mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 6f3432a..5ddfd0e 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1857,7 +1857,7 @@ static int bfin_mii_bus_probe(struct platform_device *pdev)
 	rc = mdiobus_register(miibus);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
-		goto out_err_alloc;
+		goto out_err_irq_alloc;
 	}
 
 	platform_set_drvdata(pdev, miibus);
-- 
1.9.1
