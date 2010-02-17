From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 4/8] bnx2x: fix in 57710 self-test
Date: Wed, 17 Feb 2010 14:04:00 +0200
Message-ID: <1266408241.25691.850.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2042 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756767Ab0BQMMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 07:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix: Use the last unicast entry in CAM in bnx2x_test_int(). Relevant for 57710 only.

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ccdc3fe..24fe083 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10433,7 +10433,8 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 
 	config->hdr.length = 0;
 	if (CHIP_IS_E1(bp))
-		config->hdr.offset = (BP_PORT(bp) ? 32 : 0);
+		/* use last unicast entries */
+		config->hdr.offset = (BP_PORT(bp) ? 63 : 31);
 	else
 		config->hdr.offset = BP_FUNC(bp);
 	config->hdr.client_id = bp->fp->cl_id;
-- 
1.6.3.3




