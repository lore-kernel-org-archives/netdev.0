From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 3/8] ethoc: enable interrupts after napi_complete
Date: Thu, 25 Nov 2010 13:30:27 +0100
Message-ID: <1290688232-25142-4-git-send-email-jonas@southpole.se>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Cc: Adam Edvardsson <adam.edvardsson@orsoc.se>,
	Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38970 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab0KYMaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:35 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
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
index e9e712e..db444a7 100644
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

