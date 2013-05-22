From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 14:12:51 -0700
Message-ID: <1369257171.2143.120.camel@joe-AO722>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
	 <1369246816.2143.84.camel@joe-AO722>
	 <1369250772.3301.349.camel@edumazet-glaptop>
	 <1369252624.2143.103.camel@joe-AO722>
	 <1369253761.3301.355.camel@edumazet-glaptop>
	 <1369255104.2143.108.camel@joe-AO722>
	 <1369255736.3301.358.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369255736.3301.358.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-22 at 13:48 -0700, Eric Dumazet wrote:
> On Wed, 2013-05-22 at 13:38 -0700, Joe Perches wrote:
> 
> > u16 for cpu is hardly used at all.
> 
> Its used in network tree.
> 
> The day it has to change, don't worry, I think we'll be able to handle
> it.
> 
> For the meantime, I do not want to add 4 more bytes to conntrack
> structure, its already bloated enough.

I wrote "nice" already, no worries.

btw: netdevice.h could possibly convert xmit_lock_owner
to u16 as well for that same 4 byte savings if the -1
test was converted too.
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 60584b1..c38cd29 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -528,7 +528,7 @@ struct netdev_queue {
  * write mostly part
  */
 	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
-	int			xmit_lock_owner;
+	u16			xmit_lock_owner;
 	/*
 	 * please use this field instead of dev->trans_start
 	 */
@@ -2453,7 +2453,7 @@ static inline void __netif_tx_unlock_bh(struct netdev_queue *txq)
 
 static inline void txq_trans_update(struct netdev_queue *txq)
 {
-	if (txq->xmit_lock_owner != -1)
+	if (txq->xmit_lock_owner != (u16)-1)
 		txq->trans_start = jiffies;
 }
 



