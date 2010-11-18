From: David Miller <davem@davemloft.net>
Subject: [PATCH] atm: fore200e: Fix build warning.
Date: Thu, 18 Nov 2010 11:53:31 -0800 (PST)
Message-ID: <20101118.115331.233701526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758493Ab0KRTxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 14:53:06 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BD2F124C088
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 11:53:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


GCC (rightfully) complains that:

drivers/atm/fore200e.c:614:5: warning: operation on 'cmdq->head' may be undefined

This is due to the FORE200E_NEXT_ENTRY macro, which essentially
evaluates to:

	i = ++i % m

Make it what's explicitly intended here which is:

	i = (i + 1) % m

and the warning goes away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/fore200e.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index c8fc69c..c097619 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -92,7 +92,7 @@
 
 #define FORE200E_INDEX(virt_addr, type, index)     (&((type *)(virt_addr))[ index ])
 
-#define FORE200E_NEXT_ENTRY(index, modulo)         (index = ++(index) % (modulo))
+#define FORE200E_NEXT_ENTRY(index, modulo)         (index = ((index) + 1) % (modulo))
 
 #if 1
 #define ASSERT(expr)     if (!(expr)) { \
-- 
1.7.3.2

