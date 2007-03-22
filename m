From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Fix fib_rules dump race
Date: Thu, 22 Mar 2007 15:38:19 +0100
Message-ID: <460294DB.7000507@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040006040401080506070903"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37560 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933015AbXCVOiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 10:38:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040006040401080506070903
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------040006040401080506070903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix fib_rules dump race

fib_rules_dump needs to use list_for_each_entry_rcu to protect against
concurrent changes to the rules list.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 215f1bf..3aea4e8 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -374,7 +374,7 @@ int fib_rules_dump(struct sk_buff *skb, struct netlink_callback *cb, int family)
 		return -EAFNOSUPPORT;
 
 	rcu_read_lock();
-	list_for_each_entry(rule, ops->rules_list, list) {
+	list_for_each_entry_rcu(rule, ops->rules_list, list) {
 		if (idx < cb->args[0])
 			goto skip;
 

--------------040006040401080506070903--
