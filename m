From: Jasper Spaans <spaans@fox-it.com>
Subject: [PATCH] Modify bonding hash transmit policies to use the packet's
	source MAC address
Date: Fri, 23 Oct 2009 16:08:46 +0200
Message-ID: <20091023140845.GA24564@spaans.fox.local>
References: <4AE1A37F.8010203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:17472 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbZJWOIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 10:08:47 -0400
Content-Disposition: inline
In-Reply-To: <4AE1A37F.8010203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify bonding hash transmit policies to use the psource MAC address of
the packet instead of the MAC address configured for the bonding device.

The old sitation conflicts with the documentation.

Signed-off-by: Jasper Spaans <spaans@fox-it.com>
---
 drivers/net/bonding/bond_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69c5b15..3f05267 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3665,10 +3665,10 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
-			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
+			(data->h_dest[5] ^ data->h_source[5])) % count;
 	}
 
-	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
+	return (data->h_dest[5] ^ data->h_source[5]) % count;
 }
 
 /*
@@ -3695,7 +3695,7 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb,
 
 	}
 
-	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
+	return (data->h_dest[5] ^ data->h_source[5]) % count;
 }
 
 /*
@@ -3706,7 +3706,7 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 
-	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
+	return (data->h_dest[5] ^ data->h_source[5]) % count;
 }
 
 /*-------------------------- Device entry points ----------------------------*/
-- 
1.6.0.4


-- 
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624
