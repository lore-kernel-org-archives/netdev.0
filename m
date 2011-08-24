From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] mcast: Fix source address selection for multicast listener
 report
Date: Wed, 24 Aug 2011 16:54:37 +0800
Message-ID: <4E54BC4D.8090008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dlstevens@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23550 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659Ab1HXIys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 04:54:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should check use count of include mode filter instead of total number
of include mode filters.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

---
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 283c0a2..d577199 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -767,7 +767,7 @@ static int igmp_xmarksources(struct ip_mc_list *pmc, int nsrcs, __be32 *srcs)
 			break;
 		for (i=0; i<nsrcs; i++) {
 			/* skip inactive filters */
-			if (pmc->sfcount[MCAST_INCLUDE] ||
+			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->sfcount[MCAST_EXCLUDE] !=
 			    psf->sf_count[MCAST_EXCLUDE])
 				continue;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 3e6ebcd..ee7839f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1059,7 +1059,7 @@ static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 			break;
 		for (i=0; i<nsrcs; i++) {
 			/* skip inactive filters */
-			if (pmc->mca_sfcount[MCAST_INCLUDE] ||
+			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
 			    psf->sf_count[MCAST_EXCLUDE])
 				continue;
