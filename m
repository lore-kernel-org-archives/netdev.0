From: roy.qing.li@gmail.com
Subject: [PATCH net-next] net: replace continue with break to reduce unnecessary loop in xxx_xmarksources
Date: Thu,  5 Apr 2012 17:36:29 +0800
Message-ID: <1333618589-13839-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:59240 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab2DEJgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 05:36:37 -0400
Received: by qcro28 with SMTP id o28so721598qcr.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 02:36:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

The conditional which decides to skip inactive filters does not
change with the change of loop index, so it is unnecessary to
check them many times.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv4/igmp.c  |    2 +-
 net/ipv6/mcast.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5dfecfd..ceaac24 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -774,7 +774,7 @@ static int igmp_xmarksources(struct ip_mc_list *pmc, int nsrcs, __be32 *srcs)
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->sfcount[MCAST_EXCLUDE] !=
 			    psf->sf_count[MCAST_EXCLUDE])
-				continue;
+				break;
 			if (srcs[i] == psf->sf_inaddr) {
 				scount++;
 				break;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index b2869ca..7dfb89f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1061,7 +1061,7 @@ static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
 			    psf->sf_count[MCAST_EXCLUDE])
-				continue;
+				break;
 			if (ipv6_addr_equal(&srcs[i], &psf->sf_addr)) {
 				scount++;
 				break;
-- 
1.7.1
