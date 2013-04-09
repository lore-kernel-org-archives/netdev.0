From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 01/11] tg3: Fix flow control settings not
 propagated to hardware
Date: Tue, 9 Apr 2013 11:48:01 -0700
Message-ID: <1365533291-5672-2-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2271 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934841Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tg3_setup_copper_phy(), if autonegotiation is disabled, we need to
relink only if the speed or duplex does not match the configured
setting.  If flow control does not match, a relink is not necessary as
flow control is not a PHY setting.  Later on, we'll call
tg3_setup_flow_ctrl() to set up the MAC to the desired flow control
settings if we're in full duplex mode.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a4416b0..d044adf 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4587,9 +4587,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 		} else {
 			if (!(bmcr & BMCR_ANENABLE) &&
 			    tp->link_config.speed == current_speed &&
-			    tp->link_config.duplex == current_duplex &&
-			    tp->link_config.flowctrl ==
-			    tp->link_config.active_flowctrl) {
+			    tp->link_config.duplex == current_duplex) {
 				current_link_up = 1;
 			}
 		}
-- 
1.8.1.4
