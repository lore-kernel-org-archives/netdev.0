From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] net: Make UFO on master device independent of attached
 devices
Date: Wed, 07 Oct 2009 15:24:25 -0700
Message-ID: <1254954265.31575.191.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35625 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944AbZJGWZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 18:25:07 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n97MM7Yu022338
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2009 16:22:07 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n97MORsK265090
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2009 16:24:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n97MOQLo012795
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2009 16:24:26 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that software UFO is supported, UFO can be enabled on master
devices like bridge, bond even though the attached device doesn't
support this feature in hardware.

This allows UFO to be used between KVM host and guest even when a
physical interface attached to the bridge doesn't support UFO.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
 
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5483,7 +5483,7 @@ unsigned long netdev_increment_features(unsigned long all, unsigned long one,
 	one |= NETIF_F_ALL_CSUM;
 
 	one |= all & NETIF_F_ONE_FOR_ALL;
-	all &= one | NETIF_F_LLTX | NETIF_F_GSO;
+	all &= one | NETIF_F_LLTX | NETIF_F_GSO | NETIF_F_UFO;
 	all |= one & mask & NETIF_F_ONE_FOR_ALL;
 
 	return all;


