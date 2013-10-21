From: Nate Klein <nxk@google.com>
Subject: [PATCH] net-bnx2x: Fix byte order problem on NVRAM writes
Date: Mon, 21 Oct 2013 14:57:01 -0700
Message-ID: <1382392621-8998-1-git-send-email-nxk@google.com>
Cc: eilong@broadcom.com, nxk@google.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:60025 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab3JUV5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 17:57:39 -0400
Received: by mail-pd0-f201.google.com with SMTP id y10so515495pdj.2
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 14:57:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested:
    ethtool -e eth0 raw on >first.nvram
    ethtool -E eth0 <first.nvram
    ethtool -e eth0 raw on >second.nvram
    cmp first.nvram second.nvram || ethtool -E eth0 <second.nvram
    (No output means pass.)
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 8213cc8..35671fb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1549,7 +1549,7 @@ static int bnx2x_nvram_write_dword(struct bnx2x *bp, u32 offset, u32 val,
 	REG_WR(bp, MCP_REG_MCPR_NVM_COMMAND, MCPR_NVM_COMMAND_DONE);
 
 	/* write the data */
-	REG_WR(bp, MCP_REG_MCPR_NVM_WRITE, val);
+	REG_WR(bp, MCP_REG_MCPR_NVM_WRITE, cpu_to_be32(val));
 
 	/* address of the NVRAM to write to */
 	REG_WR(bp, MCP_REG_MCPR_NVM_ADDR,
-- 
1.8.4
