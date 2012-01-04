From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2 net-next] cnic: Re-init dev->stats_addr after chip
 reset
Date: Wed, 4 Jan 2012 14:12:27 -0800
Message-ID: <1325715148-1371-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3712 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757161Ab2ADWGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 17:06:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

because bnx2x frees the old and allocates new memory during chip reset.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 4bcb67e..567cb04 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -4869,6 +4869,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	int func = CNIC_FUNC(cp), ret;
 	u32 pfid;
 
+	dev->stats_addr = ethdev->addr_drv_info_to_mcp;
 	cp->port_mode = CHIP_PORT_MODE_NONE;
 
 	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
-- 
1.7.1
