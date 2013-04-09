From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 03/11] tg3: Remove unnecessary phy reset during
 ethtool commands
Date: Tue, 9 Apr 2013 11:48:03 -0700
Message-ID: <1365533291-5672-4-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2272 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934655Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code unnecessarily resets the phy when we use ethtool to
change the ring parameters or flow control settings. Remove the phy
reset.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a27310d..3f0d43f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11720,7 +11720,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		err = tg3_restart_hw(tp, 1);
+		err = tg3_restart_hw(tp, 0);
 		if (!err)
 			tg3_netif_start(tp);
 	}
@@ -11841,7 +11841,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 
 		if (netif_running(dev)) {
 			tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-			err = tg3_restart_hw(tp, 1);
+			err = tg3_restart_hw(tp, 0);
 			if (!err)
 				tg3_netif_start(tp);
 		}
-- 
1.8.1.4
