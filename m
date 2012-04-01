From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: fix array index in ip6_mc_add_src()
Date: Sun,  1 Apr 2012 16:45:26 +0800
Message-ID: <1333269926-24681-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50493 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359Ab2DAIpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 04:45:36 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so1138449wej.19
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 01:45:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

Convert array index from the loop bound to the loop index.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com> 
---
 net/ipv6/mcast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 16c33e3..c6378de 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2044,7 +2044,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		if (!delta)
 			pmc->mca_sfcount[sfmode]--;
 		for (j=0; j<i; j++)
-			(void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
+			ip6_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
 		struct ip6_sf_list *psf;
 
-- 
1.7.1
