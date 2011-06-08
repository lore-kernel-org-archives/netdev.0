From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Wed, 8 Jun 2011 15:54:11 +1000
Message-ID: <20110608155411.c3a2aa09.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ll_temac_main.c: In function 'temac_open':
drivers/net/ll_temac_main.c:859:2: error: implicit declaration of function 'request_irq'
drivers/net/ll_temac_main.c:870:2: error: implicit declaration of function 'free_irq'
drivers/net/ll_temac_main.c: In function 'temac_poll_controller':
drivers/net/ll_temac_main.c:903:2: error: implicit declaration of function 'disable_irq'
drivers/net/ll_temac_main.c:909:2: error: implicit declaration of function 'enable_irq'

Probably caused by commit a6b7a407865a ("net: remove interrupt.h
inclusion from netdevice.h").

I have added this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 8 Jun 2011 15:49:33 +1000
Subject: [PATCH] net: add needed interrupt.h

Fixes these errors after the removal of interrupt.h from netdevice.h:

drivers/net/ll_temac_main.c: In function 'temac_open':
drivers/net/ll_temac_main.c:859:2: error: implicit declaration of function 'request_irq'
drivers/net/ll_temac_main.c:870:2: error: implicit declaration of function 'free_irq'
drivers/net/ll_temac_main.c: In function 'temac_poll_controller':
drivers/net/ll_temac_main.c:903:2: error: implicit declaration of function 'disable_irq'
drivers/net/ll_temac_main.c:909:2: error: implicit declaration of function 'enable_irq'

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ll_temac_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index b7948cc..e7b8afe 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -48,6 +48,7 @@
 #include <linux/io.h>
 #include <linux/ip.h>
 #include <linux/slab.h>
+#include <linux/interrupt.h>
 
 #include "ll_temac.h"
 
-- 
1.7.5.3

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
