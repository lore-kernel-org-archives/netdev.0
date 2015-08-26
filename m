From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH V2] smsc9194: Remove uncompilable #if 0'd use of
 pr_dbg
Date: Wed, 26 Aug 2015 11:49:35 -0700
Message-ID: <1440614975.2780.40.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No pr_dbg method exists.

While this code is #if 0'd, it'd be nicer to
use the generic hex_dump, so use it instead.

Signed-off-by: Joe Perches <joe@perches.com>
---

<snorts> no print_hex_dump_dbg method exists either.

V2: Change the uncompilable print_hex_dump_dbg call to
    print_hex_dump_debug that actually could be compiled...

Or maybe just delete the driver altogether.

It'd probably be nice to one day create something
like drivers/net/ethernet/obsolete and eventually
kill off code for the stuff that hasn't been
supported or sold in the last 20 years.

 drivers/net/ethernet/smsc/smc9194.c | 32 ++------------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 67d9fde..94857c1 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1031,36 +1031,8 @@ err_out:
 static void print_packet( byte * buf, int length )
 {
 #if 0
-	int i;
-	int remainder;
-	int lines;
-
-	pr_dbg("Packet of length %d\n", length);
-	lines = length / 16;
-	remainder = length % 16;
-
-	for ( i = 0; i < lines ; i ++ ) {
-		int cur;
-
-		printk(KERN_DEBUG);
-		for ( cur = 0; cur < 8; cur ++ ) {
-			byte a, b;
-
-			a = *(buf ++ );
-			b = *(buf ++ );
-			pr_cont("%02x%02x ", a, b);
-		}
-		pr_cont("\n");
-	}
-	printk(KERN_DEBUG);
-	for ( i = 0; i < remainder/2 ; i++ ) {
-		byte a, b;
-
-		a = *(buf ++ );
-		b = *(buf ++ );
-		pr_cont("%02x%02x ", a, b);
-	}
-	pr_cont("\n");
+	print_hex_dump_debug(DRV_NAME, DUMP_PREFIX_OFFSET, 16, 1,
+			     buf, length, true);
 #endif
 }
 #endif


