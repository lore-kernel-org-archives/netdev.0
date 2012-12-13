From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ndisc: Fix padding error in link-layer address option.
Date: Thu, 13 Dec 2012 23:29:36 +0900
Message-ID: <201212131429.qBDETaa6029537@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58742 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756668Ab2LMO3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 09:29:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a natural number n exists where 2 + data_len <= 8n < 2 + data_len + pad,
post padding is not initialized correctly.

(Un)fortunately, the only type that requires pad is Infiniband,
whose pad is 2 and data_len is 20, and this logical error has not
become obvious, but it is better to fix.

Note that ndisc_opt_addr_space() handles the situation described
above correctly.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 92909d2..2ed42c8 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -151,8 +151,8 @@ static inline int ndisc_opt_addr_space(struct net_device *dev)
 static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
 				  unsigned short addr_type)
 {
-	int space = NDISC_OPT_SPACE(data_len);
 	int pad   = ndisc_addr_option_pad(addr_type);
+	int space = NDISC_OPT_SPACE(data_len + pad);
 
 	opt[0] = type;
 	opt[1] = space>>3;
-- 
1.7.9.5
