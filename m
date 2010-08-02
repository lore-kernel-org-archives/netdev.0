From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/4] u32: use get_unaligned_be32
Date: Mon, 02 Aug 2010 15:00:34 -0700
Message-ID: <20100802220113.821018357@vyatta.com>
References: <20100802220030.991706005@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58089 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057Ab0HBWJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 18:09:37 -0400
Content-Disposition: inline; filename=u32-unaligned.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

U32 classifier reads data from packet at a offset passed in from
user space. The offset should be aligned, but it is unsafe practice
to depend on values from userspace.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/cls_u32.c	2010-08-01 11:21:06.945820852 -0700
+++ b/net/sched/cls_u32.c	2010-08-01 11:24:55.257793848 -0700
@@ -41,6 +41,7 @@
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
+#include <asm/unaligned.h>
 
 struct tc_u_knode
 {
@@ -140,7 +141,7 @@ next_knode:
 			data = skb_header_pointer(skb, toff, 4, &_data);
 			if (!data)
 				goto out;
-			if ((*data ^ key->val) & key->mask) {
+			if ((get_unaligned_be32(data) ^ key->val) & key->mask) {
 				n = n->next;
 				goto next_knode;
 			}


