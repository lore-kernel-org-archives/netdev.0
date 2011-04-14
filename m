From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v2] ip6_pol_route panic: Do not propagate LOOPBACK to VLAN
Date: Thu, 14 Apr 2011 21:37:17 +0530
Message-ID: <20110414160717.32251.81326.sendpatchset@krkumar2.in.ibm.com>
References: <20110414160704.32251.17281.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:45122 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758736Ab1DNQHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 12:07:22 -0400
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p3EG1atX010642
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:01:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3EG7KaF2510940
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:07:20 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3EG7KO4011228
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:07:20 +1000
In-Reply-To: <20110414160704.32251.17281.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have tested two ways of fixing this panic:
	1. PATCH1: Do not allow vlan on lo.
	2. PATCH2: Do not propagate LOOPBACK to vlan devices.

Isn't it better to use PATCH1 and disallow vlan on lo?

The result of this patch is:

# modprobe 8021q
# vconfig add lo 43
# ifconfig lo.69 hw ether 00:80:48:BA:d1:30
# ping6 -c 3 fe80::280:48ff:feba:d130
connect: Cannot assign requested address
(no panic)

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/8021q/vlan_dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -ruNp org/net/8021q/vlan_dev.c new2/net/8021q/vlan_dev.c
--- org/net/8021q/vlan_dev.c	2011-04-14 20:42:56.000000000 +0530
+++ new2/net/8021q/vlan_dev.c	2011-04-14 20:44:35.000000000 +0530
@@ -525,7 +525,8 @@ static int vlan_dev_init(struct net_devi
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
-					  IFF_MASTER | IFF_SLAVE);
+					  IFF_MASTER | IFF_SLAVE |
+					  IFF_LOOPBACK);
 	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |
