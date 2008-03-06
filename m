From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] ivp4: igmp.c remove __inline__ and old changelog
Date: Thu, 06 Mar 2008 11:31:03 -0800
Message-ID: <1204831863.23455.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:58351 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbYCFVhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 16:37:05 -0500
Received: by wa-out-1112.google.com with SMTP id v27so83343wah.23
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 13:37:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also move EXPORT_SYMBOL() next to the function they export.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, would you be interested in a follow-on janitor patch for
some of the stylistic stuff in this file?

 net/ipv4/igmp.c |   64 ++++--------------------------------------------------
 1 files changed, 5 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 732cd07..3a27222 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -17,59 +17,6 @@
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
- *
- *	Fixes:
- *
- *		Alan Cox	:	Added lots of __inline__ to optimise
- *					the memory usage of all the tiny little
- *					functions.
- *		Alan Cox	:	Dumped the header building experiment.
- *		Alan Cox	:	Minor tweaks ready for multicast routing
- *					and extended IGMP protocol.
- *		Alan Cox	:	Removed a load of inline directives. Gcc 2.5.8
- *					writes utterly bogus code otherwise (sigh)
- *					fixed IGMP loopback to behave in the manner
- *					desired by mrouted, fixed the fact it has been
- *					broken since 1.3.6 and cleaned up a few minor
- *					points.
- *
- *		Chih-Jen Chang	:	Tried to revise IGMP to Version 2
- *		Tsu-Sheng Tsao		E-mail: chihjenc@scf.usc.edu and tsusheng@scf.usc.edu
- *					The enhancements are mainly based on Steve Deering's
- * 					ipmulti-3.5 source code.
- *		Chih-Jen Chang	:	Added the igmp_get_mrouter_info and
- *		Tsu-Sheng Tsao		igmp_set_mrouter_info to keep track of
- *					the mrouted version on that device.
- *		Chih-Jen Chang	:	Added the max_resp_time parameter to
- *		Tsu-Sheng Tsao		igmp_heard_query(). Using this parameter
- *					to identify the multicast router version
- *					and do what the IGMP version 2 specified.
- *		Chih-Jen Chang	:	Added a timer to revert to IGMP V2 router
- *		Tsu-Sheng Tsao		if the specified time expired.
- *		Alan Cox	:	Stop IGMP from 0.0.0.0 being accepted.
- *		Alan Cox	:	Use GFP_ATOMIC in the right places.
- *		Christian Daudt :	igmp timer wasn't set for local group
- *					memberships but was being deleted,
- *					which caused a "del_timer() called
- *					from %p with timer not initialized\n"
- *					message (960131).
- *		Christian Daudt :	removed del_timer from
- *					igmp_timer_expire function (960205).
- *             Christian Daudt :       igmp_heard_report now only calls
- *                                     igmp_timer_expire if tm->running is
- *                                     true (960216).
- *		Malcolm Beattie :	ttl comparison wrong in igmp_rcv made
- *					igmp_heard_query never trigger. Expiry
- *					miscalculation fixed in igmp_heard_query
- *					and random() made to return unsigned to
- *					prevent negative expiry times.
- *		Alexey Kuznetsov:	Wrong group leaving behaviour, backport
- *					fix from pending 2.1.x patches.
- *		Alan Cox:		Forget to enable FDDI support earlier.
- *		Alexey Kuznetsov:	Fixed leaving groups on device down.
- *		Alexey Kuznetsov:	Accordance to igmp-v2-06 draft.
- *		David L Stevens:	IGMPv3 support, with help from
- *					Vinay Kulkarni
  */
 
 #include <linux/module.h>
@@ -164,7 +111,7 @@ static void ip_ma_put(struct ip_mc_list *im)
  *	Timer management
  */
 
-static __inline__ void igmp_stop_timer(struct ip_mc_list *im)
+static void igmp_stop_timer(struct ip_mc_list *im)
 {
 	spin_lock_bh(&im->lock);
 	if (del_timer(&im->timer))
@@ -1244,6 +1191,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 out:
 	return;
 }
+EXPORT_SYMBOL(ip_mc_inc_group);
 
 /*
  *	Resend IGMP JOIN report; used for bonding.
@@ -1266,6 +1214,7 @@ void ip_mc_rejoin_group(struct ip_mc_list *im)
 	igmp_ifc_event(in_dev);
 #endif
 }
+EXPORT_SYMBOL(ip_mc_rejoin_group);
 
 /*
  *	A socket has left a multicast group on device dev
@@ -1295,6 +1244,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 		}
 	}
 }
+EXPORT_SYMBOL(ip_mc_dec_group);
 
 /* Device going down */
 
@@ -1780,6 +1730,7 @@ done:
 	rtnl_unlock();
 	return err;
 }
+EXPORT_SYMBOL(ip_mc_join_group);
 
 static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 			   struct in_device *in_dev)
@@ -2577,8 +2528,3 @@ int __init igmp_mc_proc_init(void)
 	return 0;
 }
 #endif
-
-EXPORT_SYMBOL(ip_mc_dec_group);
-EXPORT_SYMBOL(ip_mc_inc_group);
-EXPORT_SYMBOL(ip_mc_join_group);
-EXPORT_SYMBOL(ip_mc_rejoin_group);
-- 
1.5.4.GIT



