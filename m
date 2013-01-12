From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 1/6] ndisc: Move ndisc_opt_addr_space() to include/net/ndisc.h.
Date: Sat, 12 Jan 2013 23:21:01 +0900
Message-ID: <50F1714D.2090608@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36673 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753416Ab3ALOVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:21:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndisc_opt_addr_data() should use ndisc_opt_addr_space() and
centralizes calcuation of address space.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |    8 +++++++-
 net/ipv6/ndisc.c    |    5 -----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 23b3a7c..3c53257 100644
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
index 5733cd2..80c077c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,11 +143,6 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-static inline int ndisc_opt_addr_space(struct net_device *dev)
-{
-	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
-}
-
 static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
 				  unsigned short addr_type)
 {
-- 
1.7.9.5
