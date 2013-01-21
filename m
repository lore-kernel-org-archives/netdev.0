From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 02/19] ndisc: Move ndisc_opt_addr_space() to include/net/ndisc.h.
Date: Tue, 22 Jan 2013 01:47:56 +0900
Message-ID: <50FD713C.40408@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50333 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752397Ab3AUQr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:47:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also makes ndisc_opt_addr_data() and ndisc_fill_addr_option()
use ndisc_opt_addr_space().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |    8 +++++++-
 net/ipv6/ndisc.c    |    7 +------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index ec48f42..745bf74 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -127,13 +127,19 @@ static int ndisc_addr_option_pad(unsigned short type)
 	}
 }
 
+static inline int ndisc_opt_addr_space(struct net_device *dev)
+{
+	return NDISC_OPT_SPACE(dev->addr_len +
+			       ndisc_addr_option_pad(dev->type));
+}
+
 static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
 				      struct net_device *dev)
 {
 	u8 *lladdr = (u8 *)(p + 1);
 	int lladdrlen = p->nd_opt_len << 3;
 	int prepad = ndisc_addr_option_pad(dev->type);
-	if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len + prepad))
+	if (lladdrlen != ndisc_opt_addr_space(dev))
 		return NULL;
 	return lladdr + prepad;
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 49dfc2a..82ccf0a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,17 +143,12 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-static inline int ndisc_opt_addr_space(struct net_device *dev)
-{
-	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
-}
-
 static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
 				  struct net_device *dev)
 {
 	int pad   = ndisc_addr_option_pad(dev->type);
 	int data_len = dev->addr_len;
-	int space = NDISC_OPT_SPACE(data_len + pad);
+	int space = ndisc_opt_addr_space(dev);
 
 	opt[0] = type;
 	opt[1] = space>>3;
-- 
1.7.9.5
