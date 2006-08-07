From: Patrick McHardy <kaber@trash.net>
Subject: [IPV6]: Fix policy routing lookup
Date: Mon, 07 Aug 2006 07:19:10 +0200
Message-ID: <44D6CD4E.60009@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000206030802090808090600"
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26017 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751060AbWHGFTL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 01:19:11 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000206030802090808090600
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------000206030802090808090600
Content-Type: text/plain;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[IPV6]: Fix policy routing lookup

When the lookup in a table returns ip6_null_entry the policy routing lookup
returns it instead of continuing in the next table, which effectively means
it only searches the local table.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f5d49889512f24f3819c6aa1e0dca72061b372fe
tree 489216e0f5d31ed37d3f3cee40475b2672ad7c70
parent d3ddd45b230e8b56873c77d266004fec49c44f8b
author Patrick McHardy <kaber@trash.net> Mon, 07 Aug 2006 06:57:55 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Aug 2006 06:57:55 +0200

 net/ipv6/fib6_rules.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index c3c8195..94a46ec 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -94,8 +94,10 @@ int fib6_rule_action(struct fib_rule *ru
 
 	if (rt != &ip6_null_entry)
 		goto out;
-
 	dst_release(&rt->u.dst);
+	rt = NULL;
+	goto out;
+
 discard_pkt:
 	dst_hold(&rt->u.dst);
 out:

--------------000206030802090808090600--
