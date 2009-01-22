From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 2/4]bnx2x: Missing rmb when waiting for FW response
Date: Thu, 22 Jan 2009 18:01:29 +0200
Message-ID: <1232640089.29087.52.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Harvey Harrison" <harvey.harrison@gmail.com>,
	"Michal Kalderon" <michals@broadcom.com>, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1556 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045AbZAVQCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 11:02:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waiting for the FW to response requires a memory barrier

Signed-off-by: Michal Kalderon <michals@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 71fbf2d..f71b8a5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6622,6 +6622,7 @@ static int bnx2x_stop_leading(struct bnx2x *bp)
 		}
 		cnt--;
 		msleep(1);
+		rmb(); /* Refresh the dsb_sp_prod */
 	}
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
 	bp->fp[0].state = BNX2X_FP_STATE_CLOSED;
-- 
1.5.4.3




