From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Fix IPv4/DECnet routing rule dumping
Date: Sat, 08 Jul 2006 12:57:45 +0200
Message-ID: <44AF8FA9.9050004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000903020902010406070001"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38797 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751306AbWGHK7F
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 06:59:05 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000903020902010406070001
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit



--------------000903020902010406070001
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix IPv4/DECnet routing rule dumping

When more rules are present than fit in a single skb, the remaining rules
are incorrectly skipped.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 68fb2d31c9c960fea945f8ed81ba2200cde104d4
tree 603c24a722ebe9834b7ae337ba9f6d69cbb6258f
parent 120bda20c6f64b32e8bfbdd7b34feafaa5f5332e
author Patrick McHardy <kaber@trash.net> Fri, 07 Jul 2006 22:32:11 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 07 Jul 2006 22:32:11 +0200

 net/decnet/dn_rules.c |    3 ++-
 net/ipv4/fib_rules.c  |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 06e785f..22f321d 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -399,9 +399,10 @@ int dn_fib_dump_rules(struct sk_buff *sk
 	rcu_read_lock();
 	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
 		if (idx < s_idx)
-			continue;
+			goto next;
 		if (dn_fib_fill_rule(skb, r, cb, NLM_F_MULTI) < 0)
 			break;
+next:
 		idx++;
 	}
 	rcu_read_unlock();
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 6c642d1..773b12b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -457,13 +457,13 @@ int inet_dump_rules(struct sk_buff *skb,
 
 	rcu_read_lock();
 	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-
 		if (idx < s_idx)
-			continue;
+			goto next;
 		if (inet_fill_rule(skb, r, NETLINK_CB(cb->skb).pid,
 				   cb->nlh->nlmsg_seq,
 				   RTM_NEWRULE, NLM_F_MULTI) < 0)
 			break;
+next:
 		idx++;
 	}
 	rcu_read_unlock();

--------------000903020902010406070001--
