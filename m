From: Tonyliu <Bo.Liu@windriver.com>
Subject: [PATCH 1/1] DaVinci EMAC: correct param for ISR
Date: Tue, 03 Nov 2009 09:52:22 +0800
Message-ID: <4AEF8CD6.9060804@windriver.com>
Reply-To: Bo.Liu@windriver.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060307090900050104000805"
Cc: davinci-linux-open-source-bounces@linux.davincidsp.com,
	netdev@vger.kernel.org
To: khilman@deeprootsystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48433 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600AbZKCB4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 20:56:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060307090900050104000805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------060307090900050104000805
Content-Type: text/x-patch;
 name="0001-DaVinci-EMAC-correct-param-for-ISR.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-DaVinci-EMAC-correct-param-for-ISR.patch"

>From bf855d3a1f824ab87933a64c9fc93f859b064e92 Mon Sep 17 00:00:00 2001
From: Tonyliu <Bo.Liu@windriver.com>
Date: Wed, 28 Oct 2009 11:06:48 +0800
Subject: [PATCH 1/1] DaVinci EMAC: correct param for ISR

emac_irq is declared as:

static irqreturn_t emac_irq(int irq, void *dev_id)
{
       struct net_device *ndev = (struct net_device *)dev_id;
       struct emac_priv *priv = netdev_priv(ndev);
    ... 

	Clearly emac_irq() needs "struct net_device *" as "void *dev_id", so correct this.

Signed-off-by: Tonyliu <Bo.Liu@windriver.com>
---
 drivers/net/davinci_emac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index a876dce..4cf80ec 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2217,7 +2217,7 @@ void emac_poll_controller(struct net_device *ndev)
 	struct emac_priv *priv = netdev_priv(ndev);
 
 	emac_int_disable(priv);
-	emac_irq(ndev->irq, priv);
+	emac_irq(ndev->irq, ndev);
 	emac_int_enable(priv);
 }
 #endif
-- 
1.5.5.4


--------------060307090900050104000805--
