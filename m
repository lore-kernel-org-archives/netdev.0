From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] atm/ambassador: fix return code bug
Date: Sun, 1 Oct 2006 09:33:32 -0400
Message-ID: <20061001133332.GA32354@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:11240 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S932157AbWJANde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 09:33:34 -0400
To: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While auditing a 'may be used uninitialized' warning, I found a minor
bug:  make_rate() has the standard error code convention -- zero for
success, negative errno on error -- but its return type is defined as
unsigned.

Change the return type to reflect reality.

Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 4521a24..da599e6 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -915,8 +915,8 @@ #endif
 
 /********** make rate (not quite as much fun as Horizon) **********/
 
-static unsigned int make_rate (unsigned int rate, rounding r,
-			       u16 * bits, unsigned int * actual) {
+static int make_rate (unsigned int rate, rounding r,
+		      u16 * bits, unsigned int * actual) {
   unsigned char exp = -1; // hush gcc
   unsigned int man = -1;  // hush gcc
   
