From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [RFC] [IPV4][IPV6][TCP] remove skb->dev NULL assignation in tcp_v[4|6]_rcv
 functions
Date: Thu, 07 Feb 2008 12:17:27 +0100
Message-ID: <47AAE8C7.9090109@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030100080106040600000102"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:57674 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbYBGLXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 06:23:16 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m17BNEoS070890
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 11:23:14 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m17BNE3a1490992
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 12:23:14 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m17BNErV002579
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 12:23:14 +0100
Received: from mai.toulouse-stg.fr.ibm.com (ICON-9-167-233-221.megacenter.de.ibm.com [9.167.233.221])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m17BN9Gs002433
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 12:23:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030100080106040600000102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------030100080106040600000102
Content-Type: text/x-patch;
 name="rfc-why-dev-null.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rfc-why-dev-null.patch"

Subject: [RFC] remove skb->dev NULL assignation
From: Daniel Lezcano <dlezcano@fr.ibm.com>

I was trying to figure out why in the tcp_v4_rcv/tcp_v6_rcv function,
the skb->dev field is set to NULL. There is certainly a good reason,
but I was not able to find it.

Is it possible to remove this ?

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv4/tcp_ipv4.c |    2 --
 net/ipv6/tcp_ipv6.c |    2 --
 2 files changed, 4 deletions(-)

Index: net-2.6/net/ipv4/tcp_ipv4.c
===================================================================
--- net-2.6.orig/net/ipv4/tcp_ipv4.c
+++ net-2.6/net/ipv4/tcp_ipv4.c
@@ -1661,8 +1661,6 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	skb->dev = NULL;
-
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
Index: net-2.6/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6/net/ipv6/tcp_ipv6.c
@@ -1722,8 +1722,6 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	skb->dev = NULL;
-
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {

--------------030100080106040600000102--
