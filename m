From: Jasper Spaans <spaans@fox-it.com>
Subject: [PATCH] Modify bonding hash transmit policies to use the packet's
	source MAC address
Date: Fri, 23 Oct 2009 13:58:34 +0200
Message-ID: <20091023115834.GA2216@spaans.fox.local>
References: <20091023114511.GA537@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:20242 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbZJWL6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 07:58:36 -0400
Content-Disposition: inline
In-Reply-To: <20091023114511.GA537@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify bonding hash transmit policies to use the psource MAC address of
the packet instead of the MAC address configured for the bonding device.

The old sitation conflicts with the documentation.
---
 drivers/net/bonding/bond_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69c5b15..b140b52 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3668,7 +3668,7 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
 			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
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
