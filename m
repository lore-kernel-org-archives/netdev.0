From: Steven Whitehouse <steve@chygwyn.com>
Subject: [DECNET] Fix to decnet rules compare function
Date: Fri, 11 Aug 2006 16:54:06 +0100
Message-ID: <20060811155406.GA560@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Patrick Caulfield <patrick@tykepenguin.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:34499 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S932162AbWHKPt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 11:49:59 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Here is a fix to the DECnet rules compare function where we used
32bit values rather than 16bit values. Spotted by Patrick McHardy.

Cc: Patrick McHardy <kaber@trash.net>
Cc: Patrick Caulfield <patrick@tykepenguin.com>
Signed-off-by: Steven Whitehouse <steve@chygwyn.com>


diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 878312f..977bb56 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -196,10 +197,10 @@ static int dn_fib_rule_compare(struct fi
 		return 0;
 #endif
 
-	if (tb[FRA_SRC] && (r->src != nla_get_u32(tb[FRA_SRC])))
+	if (tb[FRA_SRC] && (r->src != nla_get_u16(tb[FRA_SRC])))
 		return 0;
 
-	if (tb[FRA_DST] && (r->dst != nla_get_u32(tb[FRA_DST])))
+	if (tb[FRA_DST] && (r->dst != nla_get_u16(tb[FRA_DST])))
 		return 0;
 
 	return 1;
