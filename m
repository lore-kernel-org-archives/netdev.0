From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] ipv6: Fix "waiting for %s to become free" hang
Date: Fri, 04 Dec 2009 16:57:34 +0530
Message-ID: <20091204112734.24535.86096.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:42748 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000AbZLDL1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 06:27:32 -0500
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB4BRbTB019736
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 22:27:37 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB4BRb8U1679454
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 22:27:37 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB4BRagG031748
	for <netdev@vger.kernel.org>; Fri, 4 Dec 2009 22:27:37 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

(From code-walkthrough, and untested)

Fix "waiting for %s to become free" hang. dev has an
extra hold (by ip6mr_reg_vif) which was not dropped
before calling unregister_netdevice.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/ip6mr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -ruNp org/net/ipv6/ip6mr.c new/net/ipv6/ip6mr.c
--- org/net/ipv6/ip6mr.c	2009-12-04 16:08:07.000000000 +0530
+++ new/net/ipv6/ip6mr.c	2009-12-04 16:09:56.000000000 +0530
@@ -648,8 +648,8 @@ static int mif6_add(struct net *net, str
 			return -ENOBUFS;
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
-			unregister_netdevice(dev);
 			dev_put(dev);
+			unregister_netdevice(dev);
 			return err;
 		}
 		break;
