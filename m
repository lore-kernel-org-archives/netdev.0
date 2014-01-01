From: Yaniv Rosner <yanivr@broadcom.com>
Subject: [PATCH net 5/5] bnx2x: Fix KR2 work-around detection of BCM8073
Date: Wed, 1 Jan 2014 11:06:45 +0200
Message-ID: <1388567205-20210-6-git-send-email-yanivr@broadcom.com>
References: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:31603 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbaAAJIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:08:07 -0500
In-Reply-To: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KR2 work-around is based on detecting non-KR2 devices which may not link up
in this mode. One such link-partner is the BCM8073 which has specific
advertisement characteristics in specific mode, and this condition was not set
correctly.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 998cce3..11fc795 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -13572,7 +13572,7 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 	 */
 	not_kr2_device = (((base_page & 0x8000) == 0) ||
 			  (((base_page & 0x8000) &&
-			    ((next_page & 0xe0) == 0x2))));
+			    ((next_page & 0xe0) == 0x20))));
 
 	/* In case KR2 is already disabled, check if we need to re-enable it */
 	if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE)) {
-- 
1.7.1
