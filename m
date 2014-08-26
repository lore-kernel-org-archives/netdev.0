From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 25 Aug 2014 20:22:22 -0700 (PDT)
Message-ID: <20140825.202222.2274651017865689445.davem@davemloft.net>
References: <20140826120511.5b5dabef@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vyasevich@gmail.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552AbaHZDWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 23:22:25 -0400
In-Reply-To: <20140826120511.5b5dabef@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 26 Aug 2014 12:05:11 +1000

> Hi all,
> 
> After merging the net tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:
> 
> drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_skb_tx_csum':
> drivers/net/ethernet/marvell/mvneta.c:1374:3: error: implicit declaration of function 'vlan_get_protocol' [-Werror=implicit-function-declaration]
>    __be16 l3_proto = vlan_get_protocol(skb);
>    ^
> 
> Caused by commit 817dbfa5d1bc ("mvneta: Fix TSO and checksum for
> non-acceleration vlan traffic").
> 
> I have reverted that commit for today.

Sorry about that, I just pushed the following to fix it:

====================
[PATCH] mvneta: Add missing if_vlan.h include.

drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_skb_tx_csum':
drivers/net/ethernet/marvell/mvneta.c:1374:3: error: implicit declaration of function 'vlan_get_protocol' [-Werror=implicit-function-declaration]
   __be16 l3_proto = vlan_get_protocol(skb);
   ^

Reporeted-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/marvell/mvneta.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 133f8c6..ade067d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -20,6 +20,7 @@
 #include <linux/mbus.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <linux/io.h>
-- 
1.7.11.7
