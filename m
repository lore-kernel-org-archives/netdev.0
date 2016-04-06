From: zengzhaoxiu@163.com
Subject: [PATCH v2 30/30] ethernet: use parity8 in broadcom/tg3.c
Date: Wed,  6 Apr 2016 18:21:14 +0800
Message-ID: <1459938074-8654-1-git-send-email-zengzhaoxiu@163.com>
References: <57031D9D.801@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
To: siva.kallam@broadcom.com, prashant@broadcom.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:50668 "EHLO m50-135.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbcDFKV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 06:21:58 -0400
In-Reply-To: <57031D9D.801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3010080..802a429 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12939,11 +12939,7 @@ static int tg3_test_nvram(struct tg3 *tp)
 
 		err = -EIO;
 		for (i = 0; i < NVRAM_SELFBOOT_DATA_SIZE; i++) {
-			u8 hw8 = hweight8(data[i]);
-
-			if ((hw8 & 0x1) && parity[i])
-				goto out;
-			else if (!(hw8 & 0x1) && !parity[i])
+			if (parity8(data[i]) == !!parity[i])
 				goto out;
 		}
 		err = 0;
-- 
2.5.0
