From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/6] tg3: Fix bug in nvram write
Date: Fri, 28 Apr 2006 16:36:21 -0700
Message-ID: <1146267381.4780.18.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:43531 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030283AbWD2BRA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 21:17:00 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix bug in nvram write function. If the starting nvram address offset
happens to be the last dword of the page, the NVRAM_CMD_LAST bit will
not get set in the existing code. This patch fixes the bug by changing
the "else if" to "if" so that the last dword condition always gets
checked.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 97e27d8..0779544 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9404,7 +9404,7 @@ static int tg3_nvram_write_block_buffere
 
 	        if ((page_off == 0) || (i == 0))
 			nvram_cmd |= NVRAM_CMD_FIRST;
-		else if (page_off == (tp->nvram_pagesize - 4))
+		if (page_off == (tp->nvram_pagesize - 4))
 			nvram_cmd |= NVRAM_CMD_LAST;
 
 		if (i == (len - 4))


