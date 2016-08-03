From: skallam <siva.kallam@broadcom.com>
Subject: [PATCH net 2/2] tg3: Report the correct number of RSS queues through tg3_get_rxnfc
Date: Wed,  3 Aug 2016 09:44:00 +0530
Message-ID: <1470197640-13587-3-git-send-email-siva.kallam@broadcom.com>
References: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	prashant@broadcom.com, satish.baddipadige@broadcom.com,
	Siva Reddy Kallam <siva.kallam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:14676 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbcHCFcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 01:32:52 -0400
In-Reply-To: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy Kallam <siva.kallam@broadcom.com>

This patch remove the wrong substraction from info->data in
tg3_get_rxnfc function. Without this patch, the number of RSS
queues reported is less by one.

Reported-by: Michal Soltys <soltys@ziu.info>
Signed-off-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f3c6c91..6592612 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12552,10 +12552,6 @@ static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 				info->data = TG3_RSS_MAX_NUM_QS;
 		}
 
-		/* The first interrupt vector only
-		 * handles link interrupts.
-		 */
-		info->data -= 1;
 		return 0;
 
 	default:
-- 
1.7.1
