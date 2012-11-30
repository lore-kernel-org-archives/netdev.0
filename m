From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 16/17] solos-pci: use GFP_KERNEL where possible, not GFP_ATOMIC
Date: Fri, 30 Nov 2012 00:35:35 +0000
Message-ID: <1354235736-26833-17-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47055
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755261Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 7c56286..af19202 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -842,7 +842,7 @@ static int popen(struct atm_vcc *vcc)
 		return -EINVAL;
 	}
 
-	skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
+	skb = alloc_skb(sizeof(*header), GFP_KERNEL);
 	if (!skb) {
 		if (net_ratelimit())
 			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
@@ -882,7 +882,7 @@ static void pclose(struct atm_vcc *vcc)
 	}
 	spin_unlock(&card->tx_queue_lock);
 
-	skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
+	skb = alloc_skb(sizeof(*header), GFP_KERNEL);
 	if (!skb) {
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in pclose()\n");
 		return;
@@ -1270,7 +1270,7 @@ static int atm_init(struct solos_card *card, struct device *parent)
 		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
 		atm_dev_signal_change(card->atmdev[i], ATM_PHY_SIG_FOUND);
 
-		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
+		skb = alloc_skb(sizeof(*header), GFP_KERNEL);
 		if (!skb) {
 			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in atm_init()\n");
 			continue;
-- 
1.8.0
