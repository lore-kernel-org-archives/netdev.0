From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Wed, 07 Jul 2010 18:23:44 -0700 (PDT)
Message-ID: <20100707.182344.73667250.davem@davemloft.net>
References: <20100707143045.0c472f5d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonas@southpole.se
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100707143045.0c472f5d.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 7 Jul 2010 14:30:45 +1000

> Hi Dave,
> 
> After merging the net tree, today's linux-next build (x86_64
> allmodconfig) produced this warning:
> 
> drivers/net/ethoc.c: In function 'ethoc_init_ring':
> drivers/net/ethoc.c:302: warning: assignment makes integer from pointer without a cast
> 
> Introduced by commit f8555ad0cfb0ba6cbc8729f337341fb11c82db89 ("ethoc:
> Write bus addresses to registers").

I'll fix this as follows:

--------------------
ethoc: Fix warning in ethoc_init_ring().

Get rid of the pointless back-and-forth casting of dev->mem_start
from long to pointer back to long again.

Also fixes a warning reported by Stephen Rothwell:

drivers/net/ethoc.c: In function 'ethoc_init_ring':
drivers/net/ethoc.c:302: warning: assignment makes integer from pointer without a cast

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethoc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index db519a8..5bb6bb7 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -286,7 +286,7 @@ static inline void ethoc_disable_rx_and_tx(struct ethoc *dev)
 	ethoc_write(dev, MODER, mode);
 }
 
-static int ethoc_init_ring(struct ethoc *dev, void* mem_start)
+static int ethoc_init_ring(struct ethoc *dev, unsigned long mem_start)
 {
 	struct ethoc_bd bd;
 	int i;
@@ -670,7 +670,7 @@ static int ethoc_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	ethoc_init_ring(priv, (void*)dev->mem_start);
+	ethoc_init_ring(priv, dev->mem_start);
 	ethoc_reset(priv);
 
 	if (netif_queue_stopped(dev)) {
-- 
1.7.1.1
