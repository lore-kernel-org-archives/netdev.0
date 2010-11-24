From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 3/8] ethoc: enable interrupts after napi_complete
Date: Wed, 24 Nov 2010 14:40:53 +0100
Message-ID: <1290606058-26703-4-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Adam Edvardsson <adam.edvardsson@orsoc.se>,
	Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38158 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab0KXOCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:51 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Edvardsson <adam.edvardsson@orsoc.se>

Occasionally, it seems that some race is causing the interrupts to not be
reenabled otherwise with the end result that networking just stops working.
Enabling interrupts after calling napi_complete is more in line with what
other drivers do.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index fc8c044..53c03f2 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -569,8 +569,8 @@ static int ethoc_poll(struct napi_struct *napi, int budget)
 
 	work_done = ethoc_rx(priv->netdev, budget);
 	if (work_done < budget) {
-		ethoc_enable_irq(priv, INT_MASK_RX);
 		napi_complete(napi);
+		ethoc_enable_irq(priv, INT_MASK_RX);
 	}
 
 	return work_done;
-- 
1.7.1

