From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 5 May 2016 10:30:26 +1000
Message-ID: <20160505103026.55a46ff8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kangjie Lu <kangjielu@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:35889 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbcEEAa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 20:30:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/core/rtnetlink.c

between commit:

  5f8e44741f9f ("net: fix infoleak in rtnetlink")

from the net tree and commit:

  270cb4d05b29 ("rtnl: align nlattr properly when needed")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/core/rtnetlink.c
index 65763c29f845,d471f097c739..000000000000
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@@ -1180,17 -1173,15 +1173,17 @@@ static noinline_for_stack int rtnl_fill
  
  static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
  {
 -	struct rtnl_link_ifmap map = {
 -		.mem_start   = dev->mem_start,
 -		.mem_end     = dev->mem_end,
 -		.base_addr   = dev->base_addr,
 -		.irq         = dev->irq,
 -		.dma         = dev->dma,
 -		.port        = dev->if_port,
 -	};
 +	struct rtnl_link_ifmap map;
 +
 +	memset(&map, 0, sizeof(map));
 +	map.mem_start   = dev->mem_start;
 +	map.mem_end     = dev->mem_end;
 +	map.base_addr   = dev->base_addr;
 +	map.irq         = dev->irq;
 +	map.dma         = dev->dma;
 +	map.port        = dev->if_port;
 +
- 	if (nla_put(skb, IFLA_MAP, sizeof(map), &map))
+ 	if (nla_put_64bit(skb, IFLA_MAP, sizeof(map), &map, IFLA_PAD))
  		return -EMSGSIZE;
  
  	return 0;
