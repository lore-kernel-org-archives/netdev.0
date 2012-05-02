From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH] ipv6: Fix potential hang in mif6_add
Date: Wed, 02 May 2012 11:39:57 +0530
Message-ID: <20120502060957.30368.34595.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:33798 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab2EBGKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 02:10:46 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Wed, 2 May 2012 06:01:01 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q426A0218192242
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 16:10:00 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q426A0Xf000960
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 16:10:00 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a potential "waiting for %s to become free" hang.
mif6_add() called ip6mr_reg_vif to allocate/register a
netdevice, which also took an extra reference on the
device. On error, mif6_add should drop this reference
before unregistering the device.

(untested, noticed from code walkthrough)

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/ip6mr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -ruNp org/net/ipv6/ip6mr.c new/net/ipv6/ip6mr.c
--- org/net/ipv6/ip6mr.c	2012-04-19 09:03:34.000000000 +0530
+++ new/net/ipv6/ip6mr.c	2012-05-02 10:51:01.953110994 +0530
@@ -937,8 +937,8 @@ static int mif6_add(struct net *net, str
 			return -ENOBUFS;
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
-			unregister_netdevice(dev);
 			dev_put(dev);
+			unregister_netdevice(dev);
 			return err;
 		}
 		break;
