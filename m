From: Patrick McHardy <kaber@trash.net>
Subject: [IPV6]: Fix routing by fwmark
Date: Sat, 26 Aug 2006 13:11:26 +0200
Message-ID: <44F02C5E.3070701@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030309070104040107080702"
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56704 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964938AbWHZLNt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 07:13:49 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Netdev Mailing List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030309070104040107080702
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------030309070104040107080702
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV6]: Fix routing by fwmark

Fix mark comparison, also dump the mask to userspace when the mask is zero,
but the mark is not (in which case the mark is dumped, so the mask is needed
to make sense of it).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 829b107d9e4ef2bbbf2ccf25a748235739e9231e
tree 4ca98fb79f3e5e9cb0175ad9c074d9e4447735ac
parent 6963696ada0c98c53c2d59ca66944adb4d13e3a5
author Patrick McHardy <kaber@trash.net> Sat, 26 Aug 2006 13:12:32 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 26 Aug 2006 13:12:32 +0200

 net/ipv6/fib6_rules.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index ee4aa43..2fbc71d 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -129,7 +129,7 @@ static int fib6_rule_match(struct fib_ru
 		return 0;
 
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
-	if ((r->fwmark ^ fl->fl6_fwmark) / r->fwmask)
+	if ((r->fwmark ^ fl->fl6_fwmark) & r->fwmask)
 		return 0;
 #endif
 
@@ -256,7 +256,7 @@ #ifdef CONFIG_IPV6_ROUTE_FWMARK
 	if (rule6->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, rule6->fwmark);
 
-	if (rule6->fwmask)
+	if (rule6->fwmask || rule6->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMASK, rule6->fwmask);
 #endif
 

--------------030309070104040107080702--
