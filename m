From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Fix static checker warning regarding `txdata_ptr'
Date: Tue, 26 Aug 2014 10:24:41 +0300
Message-ID: <1409037881-4192-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
	<Ariel.Elior@qlogic.com>, <dan.carpenter@oracle.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:5536 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755391AbaHZHZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:25:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incorrect checking of array instead of array contents in panic_dump
flow - results of commit e261199872a2 ("bnx2x: Safe bnx2x_panic_dump()").

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please apply this to `net-next'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2f394b8..93132d8f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -985,7 +985,7 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 		/* Tx */
 		for_each_cos_in_tx_queue(fp, cos)
 		{
-			if (!fp->txdata_ptr)
+			if (!fp->txdata_ptr[cos])
 				break;
 
 			txdata = *fp->txdata_ptr[cos];
@@ -1140,7 +1140,7 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 		for_each_cos_in_tx_queue(fp, cos) {
 			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
 
-			if (!fp->txdata_ptr)
+			if (!fp->txdata_ptr[cos])
 				break;
 
 			if (!txdata->tx_cons_sb)
-- 
1.8.3.1
