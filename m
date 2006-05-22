From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.17 1/2] bnx2: Fix bug in bnx2_nvram_write()
Date: Mon, 22 May 2006 10:01:49 -0700
Message-ID: <1148317309.4780.116.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:24071 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751030AbWEVSlk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 14:41:40 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a bug in bnx2_nvram_write() caused by a counter variable not
correctly incremented by 4.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5ca99e2..509f104 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3061,7 +3061,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 		}
 
 		/* Loop to write the new data from data_start to data_end */
-		for (addr = data_start; addr < data_end; addr += 4, i++) {
+		for (addr = data_start; addr < data_end; addr += 4, i += 4) {
 			if ((addr == page_end - 4) ||
 				((bp->flash_info->buffered) &&
 				 (addr == data_end - 4))) {


