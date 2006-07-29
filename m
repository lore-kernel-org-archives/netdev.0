From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 18/20] [PATCH] [IPV6] MIP6: Ignore mobility headers if it is rejected.
Date: Sat, 29 Jul 2006 18:39:05 +0900
Message-ID: <11541659453607-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:52867 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422724AbWG2JjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:39:06 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ignore mobility headers if it is rejected by route optimization.
Mobility headers should be bypassed for any route optimization and
application should use transformation policy and wild-card states corerctly
to catch mobility headers prior than other packets.
This case which such reject is occurred may be either missing poilcy
or erroneous policy is inserted to kernel.
Based on MIPL2 kernel patch.
---
 net/ipv6/mip6.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index fb973d9..43d0b53 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -243,6 +243,9 @@ static int mip6_destopt_reject(struct xf
 	struct timeval stamp;
 	int err = 0;
 
+	if (unlikely(fl->proto == IPPROTO_MH && fl->fl_mh_type <= IP6_MH_TYPE_MAX))
+		goto out;
+
 	if (likely(opt->dsthao)) {
 		offset = ipv6_find_tlv(skb, opt->dsthao, IPV6_TLV_HAO);
 		if (likely(offset >= 0))
-- 
1.4.1

