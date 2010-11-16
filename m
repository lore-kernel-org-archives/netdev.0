From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 15 Nov 2010 20:15:47 -0800 (PST)
Message-ID: <20101115.201547.193717949.davem@davemloft.net>
References: <20101116113437.4f536d16.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse@nicira.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101116113437.4f536d16.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 16 Nov 2010 11:34:37 +1100

> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> ERROR: "netif_get_vlan_features" [drivers/net/xen-netfront.ko] undefined!
> 
> Caused by commit 58e998c6d23988490162cef0784b19ea274d90bb ("offloading:
> Force software GSO for multiple vlan tags").
> 
> Presumably netif_get_vlan_features needs exporting.

Thanks Stephen, I've just pushed the following fix.

--------------------
net: Export netif_get_vlan_features().

ERROR: "netif_get_vlan_features" [drivers/net/xen-netfront.ko] undefined!

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8725d16..381b8e2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1983,6 +1983,7 @@ int netif_get_vlan_features(struct sk_buff *skb, struct net_device *dev)
 	else
 		return 0;
 }
+EXPORT_SYMBOL(netif_get_vlan_features);
 
 /*
  * Returns true if either:
-- 
1.7.3.2
