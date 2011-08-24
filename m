From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: [PATCH] mcast: Fix source address selection for multicast listener report.
Date: Wed, 24 Aug 2011 15:55:04 +0800
Message-ID: <CAAM7YAku7DgV_c7joAHCx5fP8Dea3Y_VaxbokdTR3m2ADz1qhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dlstevens@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:35983 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab1HXHzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 03:55:11 -0400
Received: by pzk37 with SMTP id 37so413485pzk.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 00:55:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should check use count of include mode filter instead of total number
of include mode filters.

Signed-off-by: Zheng Yan  <zheng.z.yan@intel.com>
---
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 283c0a2..d577199 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -767,7 +767,7 @@ static int igmp_xmarksources(struct ip_mc_list
*pmc, int nsrcs, __be32 *srcs)
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
@@ -1059,7 +1059,7 @@ static int mld_xmarksources(struct ifmcaddr6
*pmc, int nsrcs,
 			break;
 		for (i=0; i<nsrcs; i++) {
 			/* skip inactive filters */
-			if (pmc->mca_sfcount[MCAST_INCLUDE] ||
+			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
 			    psf->sf_count[MCAST_EXCLUDE])
 				continue;
