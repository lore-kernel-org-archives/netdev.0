From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the tree
Date: Sun, 28 Mar 2010 18:57:07 -0700 (PDT)
Message-ID: <20100328.185707.161194820.davem@davemloft.net>
References: <20100329103139.1a735227.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kyle@mcmartin.ca
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100329103139.1a735227.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 29 Mar 2010 10:31:39 +1100

> Hi Dave,
> 
> After merging the  tree, today's linux-next build (x86_64 allmodconfig)
> produced this warning:
> 
> drivers/net/tulip/uli526x.c: In function 'uli526x_rx_packet':
> drivers/net/tulip/uli526x.c:861: warning: assignment makes pointer from integer without a cast
> 
> Introduced by commit ac90a149361a331f697d5aa500bedcff22054669 ("tulip:
> Fix null dereference in uli526x_rx_packet()") from the net-current tree.
> There is a missing set of parentheses around an assignment in an "if"
> condition ...

Strange, it didn't warn here.

I just committed the following, let me know if it fixes
this.

Thanks!

tulip: Add missing parens.

As reported by Stephen Rothwell.

drivers/net/tulip/uli526x.c: In function 'uli526x_rx_packet':
drivers/net/tulip/uli526x.c:861: warning: assignment makes pointer from integer without a cast

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tulip/uli526x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 90be57b..a4f09d4 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -858,7 +858,7 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 				/* Good packet, send to upper layer */
 				/* Shorst packet used new SKB */
 				if ((rxlen < RX_COPY_SIZE) &&
-				    ((new_skb = dev_alloc_skb(rxlen + 2) != NULL))) {
+				    (((new_skb = dev_alloc_skb(rxlen + 2)) != NULL))) {
 					skb = new_skb;
 					/* size less than COPY_SIZE, allocate a rxlen SKB */
 					skb_reserve(skb, 2); /* 16byte align */
-- 
1.7.0.3
