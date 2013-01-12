From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 2/6] ndisc: Pass net_device to ndisc_fill_addr_option().
Date: Sat, 12 Jan 2013 23:21:11 +0900
Message-ID: <50F17157.7090100@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36676 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753416Ab3ALOVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to reduction of number of arguments, this will be
used by upcoming IEEE1394 code.

CC: Stephan Gatzka <stephan.gatzka@gmail.com>
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 80c077c..99cd286 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,10 +143,11 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
-				  unsigned short addr_type)
+static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
+				  struct net_device *dev)
 {
-	int pad   = ndisc_addr_option_pad(addr_type);
+	int pad   = ndisc_addr_option_pad(dev->type);
+	int data_len = dev->addr_len;
 	int space = NDISC_OPT_SPACE(data_len + pad);
 
 	opt[0] = type;
@@ -415,8 +416,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	}
 
 	if (llinfo)
-		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr,
-				       dev->addr_len, dev->type);
+		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr, dev);
 
 	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, len,
 					   IPPROTO_ICMPV6,
@@ -1469,7 +1469,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	if (ha)
 		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, ha,
-					     dev->addr_len, dev->type);
+					     dev);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
-- 
1.7.9.5
