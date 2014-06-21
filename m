From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net v2]tg3: Change nvram command timeout value to 50ms
Date: Fri, 20 Jun 2014 23:28:15 -0700
Message-ID: <1403332095-30038-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:12384 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbaFUGcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 02:32:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 506724c463fcd63477a5e404728a980b71f80bb7 "tg3: Override clock,
link aware and link idle mode during NVRAM dump" changed the timeout
value for nvram command execution from 100ms to 1ms. But the 1ms
timeout value was only sufficient for nvram read operations but not
write operations for most of the devices supported by tg3 driver.
This patch sets the MAX to 50ms. Also it uses usleep_range instead
of udelay.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Suggested-by: David Miller <davem@davemloft.net>
---
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index df2792d..074c7c6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3224,7 +3224,7 @@ static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
 	return 0;
 }
 
-#define NVRAM_CMD_TIMEOUT 100
+#define NVRAM_CMD_TIMEOUT 5000
 
 static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
 {
@@ -3232,7 +3232,7 @@ static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
 
 	tw32(NVRAM_CMD, nvram_cmd);
 	for (i = 0; i < NVRAM_CMD_TIMEOUT; i++) {
-		udelay(10);
+		usleep_range(10, 40);
 		if (tr32(NVRAM_CMD) & NVRAM_CMD_DONE) {
 			udelay(10);
 			break;
-- 
1.7.1
