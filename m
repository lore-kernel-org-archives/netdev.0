From: "zhaoxiu.zeng" <zhaoxiu.zeng@gmail.com>
Subject: [PATCH 31/31] ethernet: broadcom: use parity8 in tg3.c
Date: Sun, 27 Mar 2016 15:50:01 +0800
Message-ID: <56F790A9.3000501@gmail.com>
References: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Siva Reddy Kallam <siva.kallam@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35064 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbcC0Hu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 03:50:28 -0400
In-Reply-To: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>
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
2.5.5
