From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ndisc: Check NS message length before access.
Date: Fri, 18 Jan 2013 21:05:03 +0900
Message-ID: <50F93A6F.9020303@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45595 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751123Ab3ARMFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 07:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check message length before accessing "target" field,
as we do for other types.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 429622d..350f860 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -671,6 +671,11 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	bool inc;
 	int is_router = -1;
 
+	if (skb->len < sizeof(struct nd_msg)) {
+		ND_PRINTK(2, warn, "NS: packet too short\n");
+		return;
+	}
+
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK(2, warn, "NS: multicast target address\n");
 		return;
-- 
1.7.9.5
