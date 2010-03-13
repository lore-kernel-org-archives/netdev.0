From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipv6: Send netlink notification when DAD fails
Date: Sat, 13 Mar 2010 19:11:17 +0800
Message-ID: <20100313111117.GA25903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40916 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758997Ab0CMLLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 06:11:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

ipv6: Send netlink notification when DAD fails

If we are managing IPv6 addresses using DHCP, it would be nice
for user-space to be notified if an address configured through
DHCP fails DAD.  Otherwise user-space would have to poll to see
whether DAD succeeds.

This patch uses the existing notification mechanism and simply
hooks it into the DAD failure code path.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 88fd8c5..01d142e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1380,6 +1380,8 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 		if (dad_failed)
 			ifp->flags |= IFA_F_DADFAILED;
 		spin_unlock_bh(&ifp->lock);
+		if (dad_failed)
+			ipv6_ifa_notify(0, ifp);
 		in6_ifa_put(ifp);
 #ifdef CONFIG_IPV6_PRIVACY
 	} else if (ifp->flags&IFA_F_TEMPORARY) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
