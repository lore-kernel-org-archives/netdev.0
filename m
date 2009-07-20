From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC][PATCH 1/2] mcastv6: Local variable shadows function
	argument
Date: Mon, 20 Jul 2009 20:26:30 +0200
Message-ID: <20090720182630.GA5903@gerrit.erg.abdn.ac.uk>
References: <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk> <OF77DEEF36.77254995-ON882575F9.005123F7-882575F9.00517F6B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63587 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751219AbZGTSa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 14:30:26 -0400
Content-Disposition: inline
In-Reply-To: <OF77DEEF36.77254995-ON882575F9.005123F7-882575F9.00517F6B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| pmc->idev should be equal to idev, so you should be able
| to simply remove the extra declaration and leave the other
| code as it is-- i.e., a 1-line change.
| 
Thank you for checking - so it would look like this?
If this is correct, it would resolve shadowing the passed idev:

--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2107,7 +2107,6 @@ static int ip6_mc_add_src(struct inet6_d
 		for (j=0; j<i; j++)
 			(void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
-		struct inet6_dev *idev = pmc->idev;
 		struct ip6_sf_list *psf;
 
 		/* filter mode change */
