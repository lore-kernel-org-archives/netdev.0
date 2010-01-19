From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH net-2.6] S2io: two branches the same in
	wait_for_cmd_complete()
Date: 19 Jan 2010 13:20:09 -0800
Message-ID: <1263936009.14256.32.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, roel.kluin@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55874 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754372Ab0ASUyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 15:54:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix check to verify if a register bit is set. We have not hit this bug because
wait_for_cmd_complete() is always called with S2IO_BIT_RESET. 
Reported by Roel Kluin <roel.kluin@gmail.com>.

Signed-off-by: Ram Vepa <ram.vepa@neterion.com>
---
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index cc42186..3c4836d 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3421,7 +3421,7 @@ static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
 				break;
 			}
 		} else {
-			if (!(val64 & busy_bit)) {
+			if (val64 & busy_bit) {
 				ret = SUCCESS;
 				break;
 			}



