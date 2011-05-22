From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 2/4] bnx2x: properly handle CFC DEL in cnic flow
Date: Sun, 22 May 2011 23:08:09 +0300
Message-ID: <1306094890.9376.3.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3618 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468Ab1EVUQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 16:16:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index a97a4a1..e237bea 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -3669,7 +3669,8 @@ static int  bnx2x_cnic_handle_cfc_del(struct bnx2x *bp, u32 cid,
 				      union event_ring_elem *elem)
 {
 	if (!bp->cnic_eth_dev.starting_cid  ||
-	    cid < bp->cnic_eth_dev.starting_cid)
+	    (cid < bp->cnic_eth_dev.starting_cid &&
+	    cid != bp->cnic_eth_dev.iscsi_l2_cid))
 		return 1;
 
 	DP(BNX2X_MSG_SP, "got delete ramrod for CNIC CID %d\n", cid);
-- 
1.7.2.2




