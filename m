From: zengzhaoxiu@163.com
Subject: [patch V4 29/31] ethernet: use parity8 in broadcom/tg3.c
Date: Wed, 11 May 2016 17:24:33 +0800
Message-ID: <1462958673-26096-1-git-send-email-zengzhaoxiu@163.com>
References: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
Cc: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>,
	Siva Reddy Kallam <siva.kallam@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
Acked-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
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
2.7.4
