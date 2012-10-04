From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 03 Oct 2012 20:50:53 -0400 (EDT)
Message-ID: <20121003.205053.1711360628623711137.davem@davemloft.net>
References: <20121004101833.019598b7e474c7b74e67ff20@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vipul@chelsio.com, jay@chelsio.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964832Ab2JDAuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 20:50:55 -0400
In-Reply-To: <20121004101833.019598b7e474c7b74e67ff20@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 4 Oct 2012 10:18:33 +1000

> After merging the net tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c: In function 't4_memory_rw':
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:420:2: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:420:7: warning: assignment makes pointer from integer without a cast [enabled by default]
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:487:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c: In function 'get_vpd_params':
> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:530:6: warning: assignment makes pointer from integer without a cast [enabled by default]
> 
> Caused by commit 8c357ebd5693 ("cxgb4: Dynamically allocate memory in
> t4_memory_rw() and get_vpd_params()").  Missing include of
> linux/vmalloc.h.
> 
> I have used the net tree from next-20121003 for today.

Thanks, I'll fix this as is shown below.

I do have a question though, it is honestly really that much easier to
revert a whole days worth of changes (and therefore not get the code
tested at all) than to simply add the obvious one liner?

It seems to me to be absolutely the wrong tradeoff in these situations.

====================
[PATCH] cxgb4: Fix build error due to missing linux/vmalloc.h include.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 745a1f5..31752b2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -43,6 +43,7 @@
 #include <linux/pci.h>
 #include <linux/spinlock.h>
 #include <linux/timer.h>
+#include <linux/vmalloc.h>
 #include <asm/io.h>
 #include "cxgb4_uld.h"
 #include "t4_hw.h"
-- 
1.7.11.4
