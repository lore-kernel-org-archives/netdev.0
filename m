From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v1] ip6_pol_route panic: Do not allow VLAN on loopback
Date: Thu, 14 Apr 2011 21:37:04 +0530
Message-ID: <20110414160704.32251.17281.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:49704 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758736Ab1DNQHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 12:07:10 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p3EG78N6006486
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:07:08 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3EG78Kr1585240
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:07:08 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3EG77q1011919
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 02:07:08 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have tested two ways of fixing this panic:
	1. PATCH1: Do not allow vlan on lo.
	2. PATCH2: Do not propagate LOOPBACK to vlan devices.

Isn't it better to use PATCH1 and disallow vlan on lo?

The result of this patch is:

# modprobe 8021q
# vconfig add lo 43
ERROR: trying to add VLAN #43 to IF -:lo:-  error: Operation not supported

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/loopback.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -ruNp org/drivers/net/loopback.c new1/drivers/net/loopback.c
--- org/drivers/net/loopback.c	2011-04-14 20:45:46.000000000 +0530
+++ new1/drivers/net/loopback.c	2011-04-14 20:47:09.000000000 +0530
@@ -173,7 +173,8 @@ static void loopback_setup(struct net_de
 		| NETIF_F_RXCSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
-		| NETIF_F_NETNS_LOCAL;
+		| NETIF_F_NETNS_LOCAL
+		| NETIF_F_VLAN_CHALLENGED;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->netdev_ops		= &loopback_ops;
