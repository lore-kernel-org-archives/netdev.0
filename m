From: Vitaly Wool <vwool@ru.mvista.com>
Subject: [PATCH] fix smc911x compilation breakage
Date: Fri, 27 Apr 2007 14:35:52 +0400
Message-ID: <20070427143552.0000757a.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:55906 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1755582AbXD0Kmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 06:42:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

currently (with 2.6.21) compilation of smc911x driver fails in the following way:

  CC      drivers/net/smc911x.o
/sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c: In function `smc911x_probe':
/sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: warning: implicit declaration of function `set_irq_type'
/sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: error: `IRQ_TYPE_EDGE_FALLING' undeclared (first use in this function)
/sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: error: (Each undeclared identifier is reported only once
/sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: error: for each function it appears in.)
make[3]: *** [drivers/net/smc911x.o] Error 1
make[2]: *** [drivers/net] Error 2
make[1]: *** [drivers] Error 2
make: *** [zImage] Error 2

The patch inlined below fixes the problem.

 smc911x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Index: linux-2.6/drivers/net/smc911x.c
===================================================================
--- linux-2.6.orig/drivers/net/smc911x.c
+++ linux-2.6/drivers/net/smc911x.c
@@ -75,9 +75,9 @@ static const char version[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/irq.h>
 
 #include <asm/io.h>
-#include <asm/irq.h>
 
 #include "smc911x.h"
 
