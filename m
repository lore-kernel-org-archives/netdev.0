From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 1/8] [Blackfin] EMAC driver: shorten the mdelay value to solve netperf performance issue
Date: Wed, 30 Jan 2008 16:52:21 +0800
Message-ID: <1201683148-23931-2-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:33791 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809AbYA3Iwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:36 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index eb97175..4006a5d 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -296,7 +296,7 @@ static void mdio_poll(void)
 
 	/* poll the STABUSY bit */
 	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
-		mdelay(10);
+		udelay(1);
 		if (timeout_cnt-- < 0) {
 			printk(KERN_ERR DRV_NAME
 			": wait MDC/MDIO transaction to complete timeout\n");
@@ -551,7 +551,7 @@ static void adjust_tx_list(void)
 	 */
 	if (current_tx_ptr->next->next == tx_list_head) {
 		while (tx_list_head->status.status_word == 0) {
-			mdelay(10);
+			mdelay(1);
 			if (tx_list_head->status.status_word != 0
 			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
 				goto adjust_head;
-- 
1.5.3.4
