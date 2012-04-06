From: "Alexey I. Froloff" <raorn@raorn.name>
Subject: [PATCH] [IPv6]: Treat ND option 31 as userland (DNSSL support)
Date: Fri,  6 Apr 2012 19:50:58 +0400
Message-ID: <1333727458-28438-1-git-send-email-raorn@raorn.name>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c2-81-23-10-117.elastic.cloud.croc.ru ([81.23.10.117]:38970
	"EHLO mail.raorn.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757212Ab2DFQJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:09:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As specified in RFC6106, DNSSL option contains one or more domain names
of DNS suffixes.  8-bit identifier of the DNSSL option type as assigned
by the IANA is 31.  This option should also be treated as userland.

Signed-off-by: Alexey I. Froloff <raorn@raorn.name>
---
 include/net/ndisc.h |    1 +
 net/ipv6/ndisc.c    |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 6f9c25a..c02b6ad 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -34,6 +34,7 @@ enum {
 	__ND_OPT_ARRAY_MAX,
 	ND_OPT_ROUTE_INFO = 24,		/* RFC4191 */
 	ND_OPT_RDNSS = 25,		/* RFC5006 */
+	ND_OPT_DNSSL = 31,		/* RFC6106 */
 	__ND_OPT_MAX
 };
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3dcdb81..d04c6eb 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -15,6 +15,7 @@
 /*
  *	Changes:
  *
+ *	Alexey I. Froloff		:	RFC6106 (DNSSL) support
  *	Pierre Ynard			:	export userland ND options
  *						through netlink (RDNSS support)
  *	Lars Fenneberg			:	fixed MTU setting on receipt
@@ -228,7 +229,8 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 
 static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
 {
-	return opt->nd_opt_type == ND_OPT_RDNSS;
+	return opt->nd_opt_type == ND_OPT_RDNSS ||
+		opt->nd_opt_type == ND_OPT_DNSSL;
 }
 
 static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
-- 
1.7.3.4
