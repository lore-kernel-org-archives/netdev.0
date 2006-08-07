From: Patrick McHardy <kaber@trash.net>
Subject: [IPV6]: Fix crash in ip6_del_rt
Date: Mon, 07 Aug 2006 07:19:05 +0200
Message-ID: <44D6CD49.4090100@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050807040604070602030503"
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24481 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751057AbWHGFTI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 01:19:08 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050807040604070602030503
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------050807040604070602030503
Content-Type: text/plain;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[IPV6]: Fix crash in ip6_del_rt

ip6_null_entry doesn't have rt6i_table set, when trying to delete it the
kernel crashes dereferencing table->tb6_lock.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d3ddd45b230e8b56873c77d266004fec49c44f8b
tree 764a548789cd495e2b424824c682734f62e9cb94
parent 10365c03ef65f5bccc992d6b78f7ef037cb4f0e9
author Patrick McHardy <kaber@trash.net> Mon, 07 Aug 2006 06:54:47 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Aug 2006 06:54:47 +0200

 net/ipv6/route.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d5c39c4..c6c3cf3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1223,6 +1223,9 @@ int ip6_del_rt(struct rt6_info *rt, stru
 	int err;
 	struct fib6_table *table;
 
+	if (rt == &ip6_null_entry)
+		return -ENOENT;
+
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
 

--------------050807040604070602030503--
