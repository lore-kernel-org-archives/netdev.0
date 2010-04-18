From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 8/13] bnx2x: use mask in test_registers() to avoid
 parity error
Date: Sun, 18 Apr 2010 17:49:45 +0300
Message-ID: <1271602186.27235.193.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4833 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755557Ab0DROuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly mask the value to be written to the register during self-test.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 484ff2b..d311476 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11219,7 +11219,7 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 
 			save_val = REG_RD(bp, offset);
 
-			REG_WR(bp, offset, wr_val);
+			REG_WR(bp, offset, (wr_val & mask));
 			val = REG_RD(bp, offset);
 
 			/* Restore the original register's value */
-- 
1.6.3.3




