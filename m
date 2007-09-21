From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] note that NETIF_F_LLTX is deprecated (was: [kvm-devel][PATCH 3/6] virtio net driver)
Date: Fri, 21 Sep 2007 16:59:54 +0200
Message-ID: <200709211659.54935.borntraeger@de.ibm.com>
References: <1190289808.7262.223.camel@localhost.localdomain> <200709211436.43964.borntraeger@de.ibm.com> <20070921140833.GA12242@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:48403 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758306AbXIUO77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 10:59:59 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8LExwdY609994
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 14:59:58 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8LExvAb2216000
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 16:59:57 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8LExvBa031206
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 16:59:57 +0200
In-Reply-To: <20070921140833.GA12242@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 21. September 2007 schrieb Herbert Xu:
> Please don't use LLTX in new drivers.  We're trying to get rid
> of it since it's
> 
> 1) unnecessary;
> 2) causes problems with AF_PACKET seeing things twice.

I suggest to document that LLTX is deprecated. 

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

---
 Documentation/networking/netdevices.txt |    3 ++-
 include/linux/netdevice.h               |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/netdevice.h
===================================================================
--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -339,7 +339,8 @@ struct net_device
 #define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
+					/* do not use LLTX in new drivers */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 
 	/* Segmentation offload features */
Index: linux-2.6/Documentation/networking/netdevices.txt
===================================================================
--- linux-2.6.orig/Documentation/networking/netdevices.txt
+++ linux-2.6/Documentation/networking/netdevices.txt
@@ -73,7 +73,8 @@ dev->hard_start_xmit:
 	has to lock by itself when needed. It is recommended to use a try lock
 	for this and return NETDEV_TX_LOCKED when the spin lock fails.
 	The locking there should also properly protect against 
-	set_multicast_list.
+	set_multicast_list. Note that the use of NETIF_F_LLTX is deprecated.
+	Dont use it for new drivers.
 
 	Context: Process with BHs disabled or BH (timer),
 	         will be called with interrupts disabled by netconsole.
