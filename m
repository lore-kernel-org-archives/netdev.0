From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 09 Aug 2006 01:05:20 +0300
Message-ID: <44D90AA0.1000408@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000407090604090600000508"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:30470 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1030227AbWHHWFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 18:05:22 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000407090604090600000508
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi David,

please apply the attached patch!

Regards,
Ville

--------------000407090604090600000508
Content-Type: text/x-patch;
 name="fib6_rule_null_route.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib6_rule_null_route.patch"

commit 1fb9864632af5a493353643e7acf970da1d4f59f
tree 569fd122cad5000077f80138a3014c390a7999f5
parent a66c990b9f6b0b9b4c4d2b84f96ddd019b7a8eb3
author Ville Nuorvala <vnuorval@tcs.hut.fi> 1155073548 +0300
committer Ville Nuorvala <vnuorval@tcs.hut.fi> 1155073548 +0300

    [IPV6]: Make sure fib6_rule_lookup doesn't return NULL
    
    The callers of fib6_rule_lookup don't expect it to return NULL,
    therefore it must return ip6_null_entry whenever fib_rule_lookup fails.
    
    Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index bf9bba8..22a2fdb 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -63,7 +63,11 @@ struct dst_entry *fib6_rule_lookup(struc
 	if (arg.rule)
 		fib_rule_put(arg.rule);
 
-	return (struct dst_entry *) arg.result;
+	if (arg.result)
+		return (struct dst_entry *) arg.result;
+
+	dst_hold(&ip6_null_entry.u.dst);
+	return &ip6_null_entry.u.dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,

--------------000407090604090600000508--
