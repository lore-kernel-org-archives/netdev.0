From: David Miller <davem@davemloft.net>
Subject: Re: tun routing is broken
Date: Sat, 05 Mar 2011 00:10:22 -0800 (PST)
Message-ID: <20110305.001022.183044112.davem@davemloft.net>
References: <20110304.010603.104076956.davem@davemloft.net>
	<4D70B2DC.2000005@gmail.com>
	<4D71EE86.6030309@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	netdev@vger.kernel.org, maxk@qualcomm.com
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750982Ab1CEIJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 03:09:45 -0500
In-Reply-To: <4D71EE86.6030309@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Sat, 05 Mar 2011 09:04:22 +0100

> Ok, so I booted the new kernel, and tun is broken there completely. If I
> try to ping a vpn peer:

-mm tree is missing this fix which went in yesterday.  Please if
you are going to be testing networking a lot, test against net-next-2.6
instead of Andrew's tree which invariable lags behind:

--------------------
ipv4: Fix __ip_dev_find() to use ifa_local instead of ifa_address.

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/devinet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 9038928..ff53860 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -111,7 +111,7 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
 
 static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
 {
-	unsigned int hash = inet_addr_hash(net, ifa->ifa_address);
+	unsigned int hash = inet_addr_hash(net, ifa->ifa_local);
 
 	spin_lock(&inet_addr_hash_lock);
 	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
@@ -146,7 +146,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 
 		if (!net_eq(dev_net(dev), net))
 			continue;
-		if (ifa->ifa_address == addr) {
+		if (ifa->ifa_local == addr) {
 			result = dev;
 			break;
 		}
-- 
1.7.4.1



