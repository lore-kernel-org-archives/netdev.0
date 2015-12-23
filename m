From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/9] cxgb4: Update Congestion Channel map for T6 adapter
Date: Wed, 23 Dec 2015 22:47:15 +0530
Message-ID: <1450891039-17196-6-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:7977 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933070AbbLWRQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:08 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating Congestion Channel/Priority Map in Congestion Manager Context
for T6. In T6 port 0 is mapped to channel 0 and port 1 is mapped to
channel 1. For 2 port T4/T5 adapter, port 0 is mapped to channel 0,1 and
port 1 is mapped to channel 2,3

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c613bd6..2f8c736 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5316,7 +5316,14 @@ unsigned int t4_get_mps_bg_map(struct adapter *adap, int idx)
 
 	if (n == 0)
 		return idx == 0 ? 0xf : 0;
-	if (n == 1)
+	/* In T6 (which is a 2 port card),
+	 * port 0 is mapped to channel 0 and port 1 is mapped to channel 1.
+	 * For 2 port T4/T5 adapter,
+	 * port 0 is mapped to channel 0 and 1,
+	 * port 1 is mapped to channel 2 and 3.
+	 */
+	if ((n == 1) &&
+	    (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5))
 		return idx < 2 ? (3 << (2 * idx)) : 0;
 	return 1 << idx;
 }
-- 
2.3.4
