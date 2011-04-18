From: David Miller <davem@davemloft.net>
Subject: [PATCH 34/42] irda: irproc: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:11 -0700 (PDT)
Message-ID: <20110417.173411.241440401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754144Ab1DRAeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A233D24C08A
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'd' is set but unused in irda_proc_register().

Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/irproc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/irda/irproc.c b/net/irda/irproc.c
index 318766e..b9ac598 100644
--- a/net/irda/irproc.c
+++ b/net/irda/irproc.c
@@ -65,15 +65,14 @@ static const struct irda_entry irda_dirs[] = {
 void __init irda_proc_register(void)
 {
 	int i;
-	struct proc_dir_entry *d;
 
 	proc_irda = proc_mkdir("irda", init_net.proc_net);
 	if (proc_irda == NULL)
 		return;
 
 	for (i = 0; i < ARRAY_SIZE(irda_dirs); i++)
-		d = proc_create(irda_dirs[i].name, 0, proc_irda,
-				irda_dirs[i].fops);
+		(void) proc_create(irda_dirs[i].name, 0, proc_irda,
+				   irda_dirs[i].fops);
 }
 
 /*
-- 
1.7.4.3

