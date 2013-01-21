From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 01/19] ndisc: Reduce number of arguments for ndisc_fill_addr_option().
Date: Tue, 22 Jan 2013 01:47:50 +0900
Message-ID: <50FD7136.2060703@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50330 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752397Ab3AUQrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:47:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pointer to struct net_device (dev) and remove
data_len (= dev->addr_len) and addr_type (= dev->type).

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 067a0d2..49dfc2a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -148,10 +148,11 @@ static inline int ndisc_opt_addr_space(struct net_device *dev)
 	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
 }
 
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
@@ -420,8 +421,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	}
 
 	if (llinfo)
-		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr,
-				       dev->addr_len, dev->type);
+		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr, dev);
 
 	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, len,
 					   IPPROTO_ICMPV6,
@@ -1469,8 +1469,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	 */
 
 	if (ha)
-		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, ha,
-					     dev->addr_len, dev->type);
+		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, ha, dev);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
-- 
1.7.9.5
