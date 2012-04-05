From: roy.qing.li@gmail.com
Subject: [PATCH v2] ipv6: fix array index in ip6_mc_add_src()
Date: Thu,  5 Apr 2012 10:47:04 +0800
Message-ID: <1333594024-24347-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:48735 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab2DECrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 22:47:11 -0400
Received: by qadc11 with SMTP id c11so627387qad.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 19:47:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

Convert array index from the loop bound to the loop index.

And remove the void type conversion to ip6_mc_del1_src() return 
code, seem it is unnecessary, since ip6_mc_del1_src() does not 
use __must_check similar attribute, no compiler will report the
warning when it is removed.

v2: enrich the commit header

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
