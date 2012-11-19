From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 2/2] net: mvneta: fix section mismatch warning caused by mvneta_deinit()
Date: Mon, 19 Nov 2012 15:13:16 +0100
Message-ID: <1353334396-26128-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-arm-kernel@lists.infradead.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:38258 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab2KSONm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 09:13:42 -0500
In-Reply-To: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mvneta_deinit() can be called from the ->probe() hook in the error
path, so it shouldn't be marked as __devexit. It fixes the following
section mismatch warning:

WARNING: vmlinux.o(.devinit.text+0x239c): Section mismatch in reference
from the function mvneta_probe() to the function .devexit.text:mvneta_deinit()
The function __devinit mvneta_probe() references
a function __devexit mvneta_deinit().

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c90382a..ad0b551 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2605,7 +2605,7 @@ static int __devinit mvneta_init(struct mvneta_port *pp, int phy_addr)
 	return 0;
 }
 
-static void __devexit mvneta_deinit(struct mvneta_port *pp)
+static void mvneta_deinit(struct mvneta_port *pp)
 {
 	kfree(pp->txqs);
 	kfree(pp->rxqs);
-- 
1.7.9.5
