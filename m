From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: ipv6_chk_acast_addr remove unused loop
Date: Fri, 08 Feb 2008 18:23:09 +0100
Message-ID: <47AC8FFD.3090401@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030300020407010100050603"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	=?UTF-8?B?WU9TSElGVUpJIEhp?=
	 =?UTF-8?B?ZGVha2kgLyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:35525 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762650AbYBHR3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 12:29:18 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m18HTHT6021278
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 17:29:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18HTH3f5074998
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 17:29:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18HTDJ5030521
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 17:29:13 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030300020407010100050603
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



--------------030300020407010100050603
Content-Type: text/x-patch;
 name="ipv6_chk_acast_addr-remove-loop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6_chk_acast_addr-remove-loop.patch"

Subject: ipv6_chk_acast_addr remove unused loop
From: Daniel Lezcano <dlezcano@fr.ibm.com>

The ipv6_chk_acast_addr is called with a netdev pointer parameter which
can be NULL. This value is used as a wildcard to browse the netdev list
and search if a device is owning the address. But when looking closely
to the code, this function is only called one time in ndisc.c and the
netdev parameter is never NULL. The code browsing the netdev list is
pointless in this case.

This patch removes netdev list browsing code.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/anycast.c |   22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

Index: net-2.6-fixes/net/ipv6/anycast.c
===================================================================
--- net-2.6-fixes.orig/net/ipv6/anycast.c
+++ net-2.6-fixes/net/ipv6/anycast.c
@@ -401,7 +401,7 @@ static int ipv6_dev_ac_dec(struct net_de
 /*
  *	check if the interface has this anycast address
  */
-static int ipv6_chk_acast_dev(struct net_device *dev, struct in6_addr *addr)
+int ipv6_chk_acast_addr(struct net_device *dev, struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
 	struct ifacaddr6 *aca;
@@ -419,26 +419,6 @@ static int ipv6_chk_acast_dev(struct net
 	return 0;
 }
 
-/*
- *	check if given interface (or any, if dev==0) has this anycast address
- */
-int ipv6_chk_acast_addr(struct net_device *dev, struct in6_addr *addr)
-{
-	int found = 0;
-
-	if (dev)
-		return ipv6_chk_acast_dev(dev, addr);
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev)
-		if (ipv6_chk_acast_dev(dev, addr)) {
-			found = 1;
-			break;
-		}
-	read_unlock(&dev_base_lock);
-	return found;
-}
-
-
 #ifdef CONFIG_PROC_FS
 struct ac6_iter_state {
 	struct net_device *dev;

--------------030300020407010100050603--
