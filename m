From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/12] IPv6: addrconf cleanup addrconf_verify
Date: Tue, 02 Mar 2010 15:32:55 -0800
Message-ID: <20100302234003.694261909@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58968 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757629Ab0CBXrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:47 -0500
Content-Disposition: inline; filename=addrconf-verify-clean.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable regen_advance is only used in the privacy case.
Move it to simplify code and eliminate ifdef's

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-03-02 14:46:44.709576675 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:46:46.017202416 -0800
@@ -3122,9 +3122,6 @@ restart:
 		hlist_for_each_entry_rcu(ifp, node,
 					 &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
-#ifdef CONFIG_IPV6_PRIVACY
-			unsigned long regen_advance;
-#endif
 
 			if (ifp->flags & IFA_F_PERMANENT)
 				continue;
@@ -3132,12 +3129,6 @@ restart:
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
@@ -3171,6 +3162,10 @@ restart:
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

