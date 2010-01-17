From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] S2io: two branches the same in wait_for_cmd_complete()
Date: Sun, 17 Jan 2010 16:10:04 +0100
Message-ID: <4B53284C.1090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:59752 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836Ab0AQPFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 10:05:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regardless of the bit_state, the branches execute the same code.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/s2io.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

Maybe something else was intended?
this was introduced in commit 9fc93a41a1ad11

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index cc42186..0e353d6 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3415,16 +3415,9 @@ static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
 
 	do {
 		val64 = readq(addr);
-		if (bit_state == S2IO_BIT_RESET) {
-			if (!(val64 & busy_bit)) {
-				ret = SUCCESS;
-				break;
-			}
-		} else {
-			if (!(val64 & busy_bit)) {
-				ret = SUCCESS;
-				break;
-			}
+		if (!(val64 & busy_bit)) {
+			ret = SUCCESS;
+			break;
 		}
 
 		if (in_interrupt())
