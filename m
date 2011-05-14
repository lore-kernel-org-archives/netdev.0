From: Maxin B John <maxin.john@gmail.com>
Subject: [PATCH] net: ipv6: mcast: Removing invalid check
Date: Sat, 14 May 2011 16:43:07 +0300
Message-ID: <20110514134307.GA3603@maxin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, pekkas@netcore.fi,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the variable 'first' is assigned to 1, the check
"if (truncate && !first)" will always be false.

Thanks to Coverity for spotting this issue.

Signed-off-by: Maxin B. John <maxin.john@gmail.com>
---
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 76b8937..441c1a4 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1536,8 +1536,6 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 
 		if (AVAILABLE(skb) < sizeof(*psrc) +
 		    first*sizeof(struct mld2_grec)) {
-			if (truncate && !first)
-				break;	 /* truncate these */
 			if (pgr)
 				pgr->grec_nsrcs = htons(scount);
 			if (skb)
