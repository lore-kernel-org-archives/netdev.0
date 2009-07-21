From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCHv2 1/2] mcastv6: Local variable shadows function argument
Date: Tue, 21 Jul 2009 20:11:53 +0200
Message-ID: <20090721181153.GA5970@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:42268 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751674AbZGUSME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 14:12:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

can you please apply this small one.
Thanks to David L Stevens for clarification.

Gerrit

>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
mcastv6: Local variable shadows function argument

The local variable 'idev' shadows the function argument 'idev' to
ip6_mc_add_src(). Fixed by removing the local declaration, as pmc->idev
should be identical with 'idev' passed as argument.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: David L Stevens <dlstevens@us.ibm.com>
---
 net/ipv6/mcast.c |    1 -
 1 file changed, 1 deletion(-)

--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2107,7 +2107,6 @@ static int ip6_mc_add_src(struct inet6_d
 		for (j=0; j<i; j++)
 			(void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
-		struct inet6_dev *idev = pmc->idev;
 		struct ip6_sf_list *psf;
 
 		/* filter mode change */
