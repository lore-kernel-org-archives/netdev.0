From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 24/36] bnx2x: Check unzip return code
Date: Wed, 12 Aug 2009 21:23:48 +0300
Message-ID: <1250101428.27379.176.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3172 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619AbZHLSYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this check, when running out of memory, we will see PSOD's in
bnx2x_init_fill() when doing a memset().  This is because at that time,
bp->gunzip_buf is not pointing to a valid allocated space.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index cfcc4ee..656ee97 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6511,7 +6511,9 @@ static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 
 	bp->dmae_ready = 0;
 	mutex_init(&bp->dmae_mutex);
-	bnx2x_gunzip_init(bp);
+	rc = bnx2x_gunzip_init(bp);
+	if (rc)
+		return rc;
 
 	switch (load_code) {
 	case FW_MSG_CODE_DRV_LOAD_COMMON:
-- 
1.5.4.3




