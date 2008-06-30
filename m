From: Patrick McHardy <kaber@trash.net>
Subject: net: fib_rules: fix error code for unsupported families
Date: Mon, 30 Jun 2008 22:21:50 +0200
Message-ID: <4869405E.9030807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000506060508050005040803"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45420 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbYF3UVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 16:21:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000506060508050005040803
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000506060508050005040803
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 92cfe56bb3a0b93db12f84618660fdc0153523eb
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 30 22:19:48 2008 +0200

    net: fib_rules: fix error code for unsupported families
    
    The errno code returned must be negative.
    
    Fixes "RTNETLINK answers: Unknown error 18446744073709551519".
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index e3e9ab0..277a230 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -226,7 +226,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 
 	ops = lookup_rules_ops(net, frh->family);
 	if (ops == NULL) {
-		err = EAFNOSUPPORT;
+		err = -EAFNOSUPPORT;
 		goto errout;
 	}
 
@@ -365,7 +365,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 
 	ops = lookup_rules_ops(net, frh->family);
 	if (ops == NULL) {
-		err = EAFNOSUPPORT;
+		err = -EAFNOSUPPORT;
 		goto errout;
 	}
 

--------------000506060508050005040803--
