From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] IPv6: addrconf cleanup addrconf_verify
Date: Wed, 17 Mar 2010 23:31:17 -0700
Message-ID: <20100318063123.441975388@vyatta.com>
References: <20100318063108.109693694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:33134 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194Ab0CRGgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 02:36:44 -0400
Content-Disposition: inline; filename=addrconf-verify-clean.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable regen_advance is only used in the privacy case.
Move it to simplify code and eliminate ifdef's

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-03-15 16:10:27.079211696 -0700
+++ b/net/ipv6/addrconf.c	2010-03-15 16:10:27.818899265 -0700
@@ -3124,9 +3124,6 @@ restart:
 		hlist_for_each_entry_rcu(ifp, node,
 					 &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
-#ifdef CONFIG_IPV6_PRIVACY
-			unsigned long regen_advance;
-#endif
 
 			if (ifp->flags & IFA_F_PERMANENT)
 				continue;
@@ -3134,12 +3131,6 @@ restart:
 			spin_lock(&ifp->lock);
 			age = (now - ifp->tstamp) / HZ;
 
-#ifdef CONFIG_IPV6_PRIVACY
-			regen_advance = ifp->idev->cnf.regen_max_retry *
-					ifp->idev->cnf.dad_transmits *
-					ifp->idev->nd_parms->retrans_time / HZ;
-#endif
-
 			if (ifp->valid_lft != INFINITY_LIFE_TIME &&
 			    age >= ifp->valid_lft) {
 				spin_unlock(&ifp->lock);
@@ -3173,6 +3164,10 @@ restart:
 #ifdef CONFIG_IPV6_PRIVACY
 			} else if ((ifp->flags&IFA_F_TEMPORARY) &&
 				   !(ifp->flags&IFA_F_TENTATIVE)) {
+				unsigned long regen_advance = ifp->idev->cnf.regen_max_retry *
+					ifp->idev->cnf.dad_transmits *
+					ifp->idev->nd_parms->retrans_time / HZ;
+
 				if (age >= ifp->prefered_lft - regen_advance) {
 					struct inet6_ifaddr *ifpub = ifp->ifpub;
 					if (time_before(ifp->tstamp + ifp->prefered_lft * HZ, next))

-- 

