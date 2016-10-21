From: <Sony.Chacko@cavium.com>
Subject: [PATCH net 1/1] bnx2x: Use the correct divisor value for PHC clock readings.
Date: Fri, 21 Oct 2016 02:09:17 -0400
Message-ID: <1477030157-30700-1-git-send-email-Sony.Chacko@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45563 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754086AbcJUGzD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 02:55:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

Time Sync (PTP) implementation uses the divisor/shift value for converting
the clock ticks to nanoseconds. Driver currently defines shift value as 1,
this results in the nanoseconds value to be calculated as half the actual
value. Hence the user application fails to synchronize the device clock
value with the PTP master device clock. Need to use the 'shift' value of 0.

Signed-off-by: Sony.Chacko <Sony.Chacko@cavium.com>
Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 20fe6a8..0cee4c0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -15241,7 +15241,7 @@ static void bnx2x_init_cyclecounter(struct bnx2x *bp)
 	memset(&bp->cyclecounter, 0, sizeof(bp->cyclecounter));
 	bp->cyclecounter.read = bnx2x_cyclecounter_read;
 	bp->cyclecounter.mask = CYCLECOUNTER_MASK(64);
-	bp->cyclecounter.shift = 1;
+	bp->cyclecounter.shift = 0;
 	bp->cyclecounter.mult = 1;
 }
 
-- 
1.8.3.1
