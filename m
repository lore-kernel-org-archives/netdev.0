From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 12/17] solos-pci: Fix leak of skb received for unknown vcc
Date: Fri, 30 Nov 2012 00:35:31 +0000
Message-ID: <1354235736-26833-13-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	Nathan Williams <nathan@traverse.com.au>,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47064
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755298Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Williams <nathan@traverse.com.au>

... and ensure that the next skb is set up for RX in the DMA case.

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 387052d..6258961 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -711,7 +711,8 @@ void solos_bh(unsigned long card_arg)
 						dev_warn(&card->dev->dev, "Received packet for unknown VPI.VCI %d.%d on port %d\n",
 							 le16_to_cpu(header->vpi), le16_to_cpu(header->vci),
 							 port);
-					continue;
+					dev_kfree_skb_any(skb);
+					break;
 				}
 				atm_charge(vcc, skb->truesize);
 				vcc->push(vcc, skb);
-- 
1.8.0
