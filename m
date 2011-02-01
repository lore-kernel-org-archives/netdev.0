From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: multicasts in NPAR mode
Date: Tue, 1 Feb 2011 12:57:10 +0200
Message-ID: <201102011257.11610.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
To: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3270 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132Ab1BAK52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 05:57:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip was erroneously configured to accept all multicast frames
in a normal (none-promisc) rx mode both on the RSS and on the FCoE L2 rings
when in an NPAR mode. This caused packet duplication for every received multicast
frame in this mode.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 404d93e..f40740e 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2301,15 +2301,10 @@ static void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
 		/* accept matched ucast */
 		drop_all_ucast = 0;
 	}
-	if (filters & BNX2X_ACCEPT_MULTICAST) {
+	if (filters & BNX2X_ACCEPT_MULTICAST)
 		/* accept matched mcast */
 		drop_all_mcast = 0;
-		if (IS_MF_SI(bp))
-			/* since mcast addresses won't arrive with ovlan,
-			 * fw needs to accept all of them in
-			 * switch-independent mode */
-			accp_all_mcast = 1;
-	}
+
 	if (filters & BNX2X_ACCEPT_ALL_UNICAST) {
 		/* accept all mcast */
 		drop_all_ucast = 0;
-- 
1.7.0.4


