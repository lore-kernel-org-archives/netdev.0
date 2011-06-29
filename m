From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 29 Jun 2011 16:09:01 +1000
Message-ID: <20110629160901.2d3cd6da.sfr@canb.auug.org.au>
References: <20110623152920.31b28b00.sfr@canb.auug.org.au>
	<BANLkTin+iCahNVJGKc-_26pb9zEERTc8_A@mail.gmail.com>
	<20110627152927.943c34dc.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:37764 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab1F2GJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2011 02:09:05 -0400
In-Reply-To: <20110627152927.943c34dc.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On Mon, 27 Jun 2011 15:29:27 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Thu, 23 Jun 2011 16:04:13 +0300 Alexey Dobriyan <adobriyan@gmail.com> wrote:
> >
> > On Thu, Jun 23, 2011 at 8:29 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > > After merging the final tree, today's linux-next build (powerpc
> > > allyesconfig) failed like this:
> > 
> > I build on all powerpc defconfigs, somehow this driver is not pinned
> > by any of them :^)
> 
> Well, yes, but an allmodconfig or allyesconfig build will get the error.
> 
> > > drivers/net/ll_temac_main.c:209:4: error: implicit declaration of function 'dma_unmap_single'
> 
> Is there a fix?

Again, this has taken some time to fix ...

Dave, I think you have raised my expectations too far ;-)

I have added the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 29 Jun 2011 16:03:18 +1000
Subject: [PATCH] net: include dma-mapping.h for dma_map_single etc

fixes thses build errors:

drivers/net/ll_temac_main.c: In function 'temac_dma_bd_release':
drivers/net/ll_temac_main.c:209:4: error: implicit declaration of function 'dma_unmap_single'
drivers/net/ll_temac_main.c:215:3: error: implicit declaration of function 'dma_free_coherent'
drivers/net/ll_temac_main.c: In function 'temac_dma_bd_init':
drivers/net/ll_temac_main.c:243:2: error: implicit declaration of function 'dma_alloc_coherent'
drivers/net/ll_temac_main.c:243:14: warning: assignment makes pointer from integer without a cast
drivers/net/ll_temac_main.c:251:14: warning: assignment makes pointer from integer without a cast
drivers/net/ll_temac_main.c:280:3: error: implicit declaration of function 'dma_map_single'
drivers/net/ll_temac_main.c: In function 'temac_start_xmit_done':
drivers/net/ll_temac_main.c:628:22: warning: cast to pointer from integer of different size

Caused by commit commit b7f080cfe223 ("net: remove mm.h inclusion from
netdevice.h").

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ll_temac_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index e3f1925..728fe41 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -49,6 +49,7 @@
 #include <linux/ip.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
 
 #include "ll_temac.h"
 
-- 
1.7.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
