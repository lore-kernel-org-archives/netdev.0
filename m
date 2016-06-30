From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] atm: horizon: Use setup_timer
Date: Thu, 30 Jun 2016 14:14:01 +0530
Message-ID: <20160630084401.GA5261@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36510 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbcF3IoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 04:44:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

The Coccinelle semantic patch that fixes this problem is
as follows:
@@
expression t,d,f,e1;
identifier x1;
statement S1;
@@

(
-t.data = d;
|
-t.function = f;
|
-init_timer(&t);
+setup_timer(&t,f,d);
|
-init_timer_on_stack(&t);
+setup_timer_on_stack(&t,f,d);
)
<... when != S1
t.x1 = e1;
...>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/atm/horizon.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 527bbd5..5fc81e2 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2795,9 +2795,7 @@ static int hrz_probe(struct pci_dev *pci_dev,
 	dev->atm_dev->ci_range.vpi_bits = vpi_bits;
 	dev->atm_dev->ci_range.vci_bits = 10-vpi_bits;
 
-	init_timer(&dev->housekeeping);
-	dev->housekeeping.function = do_housekeeping;
-	dev->housekeeping.data = (unsigned long) dev;
+	setup_timer(&dev->housekeeping, do_housekeeping, (unsigned long) dev);
 	mod_timer(&dev->housekeeping, jiffies);
 
 out:
-- 
1.9.1
