From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC][PATCH 1/2] mcastv6: Local variable shadows function argument
Date: Sun, 19 Jul 2009 20:38:40 +0200
Message-ID: <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <cases_of_shadowing_other_variables>
 <1248028721-24244-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54994 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751459AbZGSSiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:38:55 -0400
In-Reply-To: <1248028721-24244-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The local variable 'idev' shadows the function argument 'idev' to
ip6_mc_add_src(). 

Reported-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv6/mcast.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2107,7 +2107,6 @@ static int ip6_mc_add_src(struct inet6_d
 		for (j=0; j<i; j++)
 			(void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
-		struct inet6_dev *idev = pmc->idev;
 		struct ip6_sf_list *psf;
 
 		/* filter mode change */
@@ -2117,11 +2116,11 @@ static int ip6_mc_add_src(struct inet6_d
 			pmc->mca_sfmode = MCAST_INCLUDE;
 		/* else no filters; keep old mode for reports */
 
-		pmc->mca_crcount = idev->mc_qrv;
-		idev->mc_ifc_count = pmc->mca_crcount;
+		pmc->mca_crcount = pmc->idev->mc_qrv;
+		pmc->idev->mc_ifc_count = pmc->mca_crcount;
 		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
-		mld_ifc_event(idev);
+		mld_ifc_event(pmc->idev);
 	} else if (sf_setstate(pmc))
 		mld_ifc_event(idev);
 	spin_unlock_bh(&pmc->mca_lock);
