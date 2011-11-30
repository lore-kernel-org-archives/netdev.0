From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH 2/2] ipv6 : mcast : Delete useless parameter in ip6_mc_add1_src()
Date: Thu,  1 Dec 2011 00:21:05 +0800
Message-ID: <1322670065-13237-2-git-send-email-mypopydev@gmail.com>
References: <1322670065-13237-1-git-send-email-mypopydev@gmail.com>
Cc: netdev@vger.kernel.org, Jun Zhao <mypopydev@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:32889 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757575Ab1K3QWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 11:22:35 -0500
Received: by mail-iy0-f174.google.com with SMTP id e36so978764iag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:22:35 -0800 (PST)
In-Reply-To: <1322670065-13237-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need not to used 'delta' flag when add single-source to interface
filter source list.

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 net/ipv6/mcast.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index ee7839f..933f4c9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1914,7 +1914,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
  * Add multicast single-source filter to the interface list
  */
 static int ip6_mc_add1_src(struct ifmcaddr6 *pmc, int sfmode,
-	const struct in6_addr *psfsrc, int delta)
+	const struct in6_addr *psfsrc)
 {
 	struct ip6_sf_list *psf, *psf_prev;
 
@@ -2045,7 +2045,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfcount[sfmode]++;
 	err = 0;
 	for (i=0; i<sfcount; i++) {
-		err = ip6_mc_add1_src(pmc, sfmode, &psfsrc[i], delta);
+		err = ip6_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
 	}
-- 
1.7.2.5
