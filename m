From: David Miller <davem@davemloft.net>
Subject: Re: sumgem problems with initializiation order at a 1000SX SERDES
 card
Date: Wed, 26 Nov 2008 01:18:09 -0800 (PST)
Message-ID: <20081126.011809.241693537.davem@davemloft.net>
References: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hermann.Lauer@iwr.uni-heidelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750981AbYKZJSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 04:18:10 -0500
In-Reply-To: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Date: Tue, 25 Nov 2008 11:30:29 +0100

> PS: There is only one "writeb" call in the code to reset the PCS, but the 
> value is read with a readl. Typo ?

That is definitely a bug, which I've fixed as follows.

I don't know about the rest of your report at this point, sorry.

sungem: Fix PCS_MIICTRL register write in gem_init_phy().

Use writel not writeb.

Noticed by Hermann Lauer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/sungem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4291458..1349e41 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1714,7 +1714,7 @@ static void gem_init_phy(struct gem *gp)
 		/* Reset PCS unit. */
 		val = readl(gp->regs + PCS_MIICTRL);
 		val |= PCS_MIICTRL_RST;
-		writeb(val, gp->regs + PCS_MIICTRL);
+		writel(val, gp->regs + PCS_MIICTRL);
 
 		limit = 32;
 		while (readl(gp->regs + PCS_MIICTRL) & PCS_MIICTRL_RST) {
-- 
1.5.6.5

