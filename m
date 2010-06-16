From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-next: build warning after merge of the final tree (net
	tree related)
Date: Wed, 16 Jun 2010 13:56:30 +1000
Message-ID: <20100616035630.GB17440@gondor.apana.org.au>
References: <20100616134848.3edd4a25.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100616134848.3edd4a25.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2010 at 01:48:48PM +1000, Stephen Rothwell wrote:
> Hi Dave,
> 
> After merging the final tree, today's linux-next build (powerpc
> ppc44x_defconfig) produced this warning:
> 
> net/bridge/br_forward.c: In function '__br_deliver':
> net/bridge/br_forward.c:76: warning: passing argument 1 of 'br_netpoll_send_skb' discards qualifiers from pointer target type
> net/bridge/br_private.h:308: note: expected 'struct net_bridge_port *' but argument is of type 'const struct net_bridge_port *'

Indeed, this patch should fix the warning.

bridge: Add const to dummy br_netpoll_send_skb

The version of br_netpoll_send_skb used when netpoll is off is
missing a const thus causing a warning.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 29f6d66..4ea7986 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -300,7 +300,7 @@ static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
 	return NULL;
 }
 
-static inline void br_netpoll_send_skb(struct net_bridge_port *p,
+static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
 {
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
