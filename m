From: Alexander Aring <alex.aring@gmail.com>
Subject: [RFCv4 bluetooth-next 2/2] ipv6: add 6co as icmpv6 userspace option
Date: Mon, 14 Dec 2015 15:00:54 +0100
Message-ID: <1450101654-22633-3-git-send-email-alex.aring@gmail.com>
References: <1450101654-22633-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de, Alexander Aring <alex.aring@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35780 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbbLNOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 09:01:50 -0500
In-Reply-To: <1450101654-22633-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 6LoWPAN Context Option (6CO) as userspace option to
processing such options inside RA messages in userspace.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/ndisc.h | 1 +
 net/ipv6/ndisc.c    | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 2d8edaa..944258d 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -35,6 +35,7 @@ enum {
 	ND_OPT_ROUTE_INFO = 24,		/* RFC4191 */
 	ND_OPT_RDNSS = 25,		/* RFC5006 */
 	ND_OPT_DNSSL = 31,		/* RFC6106 */
+	ND_OPT_6CO = 34,		/* RFC6775 */
 	__ND_OPT_MAX
 };
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d6161e1..bed154e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -188,7 +188,8 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
 {
 	return opt->nd_opt_type == ND_OPT_RDNSS ||
-		opt->nd_opt_type == ND_OPT_DNSSL;
+		opt->nd_opt_type == ND_OPT_DNSSL ||
+		opt->nd_opt_type == ND_OPT_6CO;
 }
 
 static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
-- 
2.6.1
