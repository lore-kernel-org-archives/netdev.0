From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 5 of 5] IPv6: temporary address: update the timer for
	tentative addresses
Date: Sun, 23 Mar 2008 21:46:13 +0100
Message-ID: <4765830d9f3848ef14e6.1206305173@pirzuine>
References: <patchbomb.1206305168@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:38156 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbYCWUqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:46:16 -0400
In-Reply-To: <patchbomb.1206305168@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: temporary address: update the timer for tentative addresses

Even for tentative addresses, we should update the timer,
otherwise if the preferred lifetime is too short we will
miss the opportunity to regenerate the adress.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r ec551b4a5bb2 -r 4765830d9f38 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 00:38:40 2008 +0100
+++ b/net/ipv6/addrconf.c	Sun Mar 23 21:33:12 2008 +0100
@@ -3003,9 +3003,9 @@
 					goto restart;
 				}
 #ifdef CONFIG_IPV6_PRIVACY
-			} else if ((ifp->flags&IFA_F_TEMPORARY) &&
-				   !(ifp->flags&IFA_F_TENTATIVE)) {
-				if (age >= ifp->prefered_lft - regen_advance) {
+			} else if (ifp->flags&IFA_F_TEMPORARY) {
+				if (!(ifp->flags&IFA_F_TENTATIVE) &&
+				    age >= ifp->prefered_lft - regen_advance) {
 					struct inet6_ifaddr *ifpub = ifp->ifpub;
 					if (time_before(ifp->tstamp + ifp->prefered_lft * HZ, next))
 						next = ifp->tstamp + ifp->prefered_lft * HZ;
